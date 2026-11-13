//
//  ProgramProgress.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// The user's run through the First 30 Days program.
struct ProgramProgress: Codable, Equatable {
    /// Start of the local day the user counts as day 1.
    var startDate: Date
    /// The user's own words for why they're doing this, shown back to them on review days.
    var goal: String?
    var completedDays: Set<Int>
    var checkIns: [Int: ProgramCheckIn]
    /// What the user rates each day besides the built-in four, removed ones included. See `ProgramTracker`.
    var trackers: [ProgramTracker] = []
    var updatedAt: Date

    func checkIn(forDay day: Int) -> ProgramCheckIn? {
        checkIns[day]
    }

    func isTaskDone(day: Int) -> Bool {
        completedDays.contains(day)
    }

    /// Check-ins in day order.
    var orderedCheckIns: [(day: Int, checkIn: ProgramCheckIn)] {
        checkIns
            .sorted { $0.key < $1.key }
            .map { (day: $0.key, checkIn: $0.value) }
    }
}

extension ProgramProgress {
    /// Written out so progress saved before trackers existed still loads.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try container.decode(Date.self, forKey: .startDate)
        goal = try container.decodeIfPresent(String.self, forKey: .goal)
        completedDays = try container.decode(Set<Int>.self, forKey: .completedDays)
        checkIns = try container.decode([Int: ProgramCheckIn].self, forKey: .checkIns)
        trackers = try container.decodeIfPresent([ProgramTracker].self, forKey: .trackers) ?? []
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

extension ProgramProgress {

    /// Combines this device's progress with what's stored for the account.
    ///
    /// When both runs started on the same day they're the same run, so completed tasks are unioned,
    /// each day keeps its most recent check-in and each tracker its most recent change. Different start days
    /// mean the user restarted somewhere,
    /// and the most recently updated run wins.
    static func merge(local: ProgramProgress?, remote: ProgramProgress?, calendar: Calendar = .current) -> ProgramProgress? {
        guard let local else { return remote }
        guard let remote else { return local }

        let localIsNewer = local.updatedAt >= remote.updatedAt
        guard calendar.isDate(local.startDate, inSameDayAs: remote.startDate) else {
            return localIsNewer ? local : remote
        }

        var merged = localIsNewer ? local : remote
        let other = localIsNewer ? remote : local

        merged.completedDays.formUnion(other.completedDays)
        for (day, checkIn) in other.checkIns {
            if let existing = merged.checkIns[day], existing.loggedAt >= checkIn.loggedAt { continue }
            merged.checkIns[day] = checkIn
        }
        merged.trackers = mergedTrackers(merged.trackers, other.trackers)
        if merged.goal == nil {
            merged.goal = other.goal
        }
        merged.updatedAt = max(local.updatedAt, remote.updatedAt)
        return merged
    }
}

/// A quick daily check-in. Every rating runs 1...5 with 5 the best, so trends read the same way.
struct ProgramCheckIn: Codable, Equatable {
    var energy: Int
    var digestion: Int
    var sleep: Int
    var cravings: Int
    var symptoms: Set<ProgramSymptom>
    /// What the user ate besides meat, fish, eggs and animal fats. Empty means a strict day. Nil on check-ins
    /// saved before the app asked, which should be left out of anything that compares days by diet.
    var addedFoods: Set<ProgramFoodGroup>? = nil
    /// Ratings for the user's own trackers, keyed by tracker id. Ratings for removed trackers are kept.
    var trackerRatings: [String: Int]? = nil
    var note: String?
    var loggedAt: Date

    static let maxNoteLength = 280

    /// How strict the day was, or nil if the check-in predates the food question.
    var strictness: ProgramStrictness? {
        addedFoods.map(ProgramStrictness.init(addedFoods:))
    }

    func rating(forTracker id: String) -> Int? {
        trackerRatings?[id]
    }

    func rating(for metric: ProgramMetric) -> Int {
        switch metric {
        case .energy: return energy
        case .digestion: return digestion
        case .sleep: return sleep
        case .cravings: return cravings
        }
    }
}

enum ProgramMetric: String, CaseIterable, Codable, Identifiable {
    case energy
    case digestion
    case sleep
    case cravings

    static let ratingRange = 1...5

    var id: String { rawValue }

    var title: String {
        switch self {
        case .energy: return String(localized: "Energy")
        case .digestion: return String(localized: "Digestion")
        case .sleep: return String(localized: "Sleep")
        case .cravings: return String(localized: "Cravings")
        }
    }

    /// Words for ratings 1 through 5.
    var ratingLabels: [String] {
        switch self {
        case .energy:
            return [String(localized: "Very low"), String(localized: "Low"), String(localized: "Okay"), String(localized: "Good"), String(localized: "Great")]
        case .digestion:
            return [String(localized: "Very rough"), String(localized: "Rough"), String(localized: "Okay"), String(localized: "Good"), String(localized: "Great")]
        case .sleep:
            return [String(localized: "Very poor"), String(localized: "Poor"), String(localized: "Okay"), String(localized: "Good"), String(localized: "Great")]
        case .cravings:
            return [String(localized: "Constant"), String(localized: "Strong"), String(localized: "Some"), String(localized: "Mild"), String(localized: "None")]
        }
    }

    func label(forRating rating: Int) -> String {
        let labels = ratingLabels
        let index = min(max(rating, 1), labels.count) - 1
        return labels[index]
    }
}

/// Foods beyond meat, fish, eggs and animal fats, logged with each check-in so later insights can compare how
/// the user felt on stricter and looser days ("your digestion was worse on days with vegetables").
///
/// The raw values are stored on the device and in the account, so don't rename them.
enum ProgramFoodGroup: String, CaseIterable, Codable, Identifiable {
    case dairy
    case coffeeOrTea
    case spicesOrSauces
    case vegetables
    case fruitOrHoney
    case nutsOrSeeds
    case grains
    case sweets
    case alcohol
    case processedFood

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dairy: return String(localized: "Dairy")
        case .coffeeOrTea: return String(localized: "Coffee or tea")
        case .spicesOrSauces: return String(localized: "Spices or sauces")
        case .vegetables: return String(localized: "Vegetables")
        case .fruitOrHoney: return String(localized: "Fruit or honey")
        case .nutsOrSeeds: return String(localized: "Nuts or seeds")
        case .grains: return String(localized: "Bread or grains")
        case .sweets: return String(localized: "Sugar or sweets")
        case .alcohol: return String(localized: "Alcohol")
        case .processedFood: return String(localized: "Processed food")
        }
    }

    /// The loosest level a day reaches when it includes this food.
    var strictness: ProgramStrictness {
        switch self {
        case .dairy, .coffeeOrTea, .spicesOrSauces: return .withExtras
        case .vegetables, .fruitOrHoney, .nutsOrSeeds: return .somePlants
        case .grains, .sweets, .alcohol, .processedFood: return .offCarnivore
        }
    }
}

/// How strictly carnivore a day was, from strictest to loosest. A day takes the loosest level of anything eaten.
enum ProgramStrictness: Int, CaseIterable, Comparable, Codable {
    /// Only meat, fish, eggs and animal fats.
    case strict
    /// Carnivore plus common extras: dairy, coffee or tea, spices and sauces.
    case withExtras
    /// Some vegetables, fruit, honey, nuts or seeds.
    case somePlants
    /// Grains, sugar, alcohol or processed food.
    case offCarnivore

    init(addedFoods: Set<ProgramFoodGroup>) {
        self = addedFoods.map(\.strictness).max() ?? .strict
    }

    static func < (lhs: ProgramStrictness, rhs: ProgramStrictness) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .strict: return String(localized: "Strict carnivore")
        case .withExtras: return String(localized: "Carnivore plus extras")
        case .somePlants: return String(localized: "Some plant foods")
        case .offCarnivore: return String(localized: "Off carnivore")
        }
    }
}

/// Common adaptation symptoms, each with a short "what to try" tip.
enum ProgramSymptom: String, CaseIterable, Codable, Identifiable {
    case headache
    case fatigue
    case brainFog
    case cramps
    case lightheaded
    case looseStools
    case constipation
    case nausea
    case irritability
    case racingHeart

    var id: String { rawValue }

    var title: String {
        switch self {
        case .headache: return String(localized: "Headache")
        case .fatigue: return String(localized: "Tired")
        case .brainFog: return String(localized: "Brain fog")
        case .cramps: return String(localized: "Muscle cramps")
        case .lightheaded: return String(localized: "Dizzy")
        case .looseStools: return String(localized: "Loose stools")
        case .constipation: return String(localized: "Constipation")
        case .nausea: return String(localized: "Nausea")
        case .irritability: return String(localized: "Irritable")
        case .racingHeart: return String(localized: "Racing heart")
        }
    }

    /// Symptoms that need a doctor rather than a diet tweak get a warning style.
    var needsMedicalAttention: Bool {
        self == .racingHeart
    }

    var tip: String {
        switch self {
        case .headache:
            return String(localized: "Early headaches are most often low sodium. Salt your food more and try a glass of water with a pinch of salt. Not eating enough can cause them too.")
        case .fatigue:
            return String(localized: "Low energy in the first weeks usually means too little food, too little fat or too little salt. Have a bigger, fattier meal and salt it well.")
        case .brainFog:
            return String(localized: "Fogginess is common in the first week or two while your brain switches fuel. Keep salt and fat up. It usually lifts as you adapt.")
        case .cramps:
            return String(localized: "Cramps often point to low electrolytes. Salt your food and make sure you're eating enough meat, which brings potassium. If they keep happening, ask your doctor about magnesium.")
        case .lightheaded:
            return String(localized: "Feeling dizzy when you stand up is common with low sodium early on. Add salt and drink water. If you take blood pressure medication, tell your doctor, since your dose may need adjusting.")
        case .looseStools:
            return String(localized: "Very common in the first few weeks while your body adjusts to more fat. Cut back on added fats like butter and tallow, get your fat from the meat itself, and add the extras back slowly.")
        case .constipation:
            return String(localized: "Going less often is normal, since meat leaves little behind. If it's hard or painful, eat more fat, drink more water and keep your salt up.")
        case .nausea:
            return String(localized: "Usually too much added fat at once, or the opposite: lots of lean protein without enough fat. Adjust the balance at your next meal.")
        case .irritability:
            return String(localized: "Mood swings early on often come from carb withdrawal, under-eating or poor sleep. Eat until you're full and keep salt up. This usually passes.")
        case .racingHeart:
            return String(localized: "Low electrolytes can cause heart flutters, but don't treat this yourself. If it's new or frequent, or comes with chest pain, shortness of breath or fainting, get medical care right away.")
        }
    }

    /// A related article, when there's one worth reading.
    var articleId: String? {
        switch self {
        case .headache: return FirstThirtyDays.ArticleIds.carnivoreFlu
        case .fatigue: return FirstThirtyDays.ArticleIds.proteinToFatRatio
        case .brainFog: return FirstThirtyDays.ArticleIds.liftingBrainFog
        case .cramps: return FirstThirtyDays.ArticleIds.potassiumPower
        case .lightheaded: return FirstThirtyDays.ArticleIds.electrolytes
        case .looseStools: return FirstThirtyDays.ArticleIds.disasterPants
        case .constipation: return FirstThirtyDays.ArticleIds.poop
        case .nausea: return FirstThirtyDays.ArticleIds.proteinToFatRatio
        case .irritability: return FirstThirtyDays.ArticleIds.adaptationPhase
        case .racingHeart: return nil
        }
    }
}
