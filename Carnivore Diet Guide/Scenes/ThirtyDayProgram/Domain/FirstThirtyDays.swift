//
//  FirstThirtyDays.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// Content for the First 30 Days program. Week 1 is free; days 8 to 30 need Carnivore+ (see `ProgramSchedule`).
///
/// Everything here is general education, not medical advice. Keep "what's normal" notes cautious, and keep the
/// "see a doctor" lines for anything that isn't a routine adaptation symptom.
enum FirstThirtyDays {

    /// Ids of the articles the program links to, from the Articles collection.
    enum ArticleIds {
        // Free
        static let beginnersGuide = "5A9731BC-E7DC-4068-B103-469FC3003844"
        static let weightLoss = "A2777C72-657E-4B62-8E21-E5B1B9FC3968"
        static let nutrition = "8C33A266-0E82-4BF0-8CC2-A8CEEB2C7EBF"
        static let commonChallenges = "071909F1-94A8-4201-9F45-EFA0487A99B8"
        static let tipsForSuccess = "DAD5A3A6-8ECD-4DAC-A948-E21CA654FD38"
        static let planShopBatchCook = "EB409847-D6DD-4C7E-B0D0-899CA78176C8"
        static let mentalClarity = "918C2681-A693-49B7-AE40-0D0ABFE992FD"
        static let supplements = "58B81105-C667-474B-98DB-0AC3F261EEC3"
        static let workouts = "10DA2CB5-9BC7-4DE3-B392-5441387DBDAB"
        static let factsAndMyths = "8C804006-60A8-43A4-BADF-921923B4542E"
        static let energy = "6FCF45F6-2D66-48A1-96DF-A02F83B277FB"
        static let howToTransition = "BA13EAF5-1FD4-45D3-BE4B-5698B387129D"
        static let traveling = "7CE5F419-4FA5-41BA-A242-A90CFF97D870"
        static let carnivoreVsVegan = "9C018FEA-B1B2-4D64-A7EE-EDC73CC94E33"
        static let pitfalls = "A54BBE4C-F76F-4039-8E65-F0D3F6E440CF"
        static let carnivoreVsKeto = "8B3262C1-7FE6-441B-9FB5-F942094FAB70"
        static let metabolicFlexibility = "73B38774-5335-4198-B0F9-CBE5AC76F766"
        static let firstWeek = "EF68B40B-7211-43EF-816B-AC80AF6D3500"
        static let castIron = "C200DD9F-2985-41EC-BAA1-3F2F12DD5817"

        // Carnivore+
        static let lowCarbWeightLoss = "A733781F-5F4D-4C2E-AA1B-9142304D7D97"
        static let advancedCarnivore = "A7CDEE4E-9BBE-489C-809B-85652CA9EC9A"
        static let satiety = "FAB88BD8-21E5-4CC7-A70E-6541A64FD773"
        static let cookingMeat = "41F4B6E8-534E-4B45-81F1-D7C29F58C168"
        static let micronutrientDensity = "9B4AEC14-8DB7-41AA-8761-12BCAFE70D10"
        static let adaptationPhase = "E5A89AB6-6DF9-496D-8ADB-FBD7F4E47644"
        static let stayingConsistent = "CC59374D-84CF-4F90-8B42-C1783A85BD61"
        static let fastingStrategies = "618E3D71-D38E-4209-A44F-84FE465952FD"
        static let inflammation = "5CF31199-8AE6-444E-9C72-A69338770D0F"
        static let electrolytes = "D0194174-B292-4790-BE51-FDE5E384D560"
        static let workoutRecovery = "CD9F83FB-DB86-4239-8A9A-FBDFF007F1F5"
        static let heart = "B737951E-2626-4318-9292-FA4133C83E39"
        static let stayStrong = "DF8C151B-431B-4E21-B71D-04815F30AC29"
        static let diningOut = "4D01F771-C83D-4E17-984F-302BFB240A19"
        static let plantsFightBack = "6C0ECFB0-0B1D-425A-8B8F-F76A28A4034B"
        static let vitaminA = "B4547973-9E43-43F2-96D7-11085D6D171B"
        static let passTheSalt = "78BA675F-7F00-4201-8059-4A56FC761AF3"
        static let mealPrepGuide = "A674A402-16FB-461C-B8B9-D96BF4973266"
        static let magnesiumChillPill = "73439468-278F-49D7-BEAE-639BA057D5D7"
        static let eggs = "32EEBE38-A16F-4E81-A8CA-896A00BDDFB0"
        static let proteinToFatRatio = "6F42FAF3-4E64-45FA-9620-70454A214F7E"
        static let carnivoreTwoPointOh = "8636EE9E-F38A-4B38-A95C-D3BE704509A5"
        static let omega3 = "3E5FA5AF-3A9A-4C30-BB05-25E7A64B467B"
        static let ditchingTheScale = "DDD5409E-A4C4-4A75-A34F-AA61A450503E"
        static let socialFeasting = "A05548D6-3676-44C7-A831-52EDD2B93B6D"
        static let poop = "CB4F961A-8B25-4761-96D5-A07CD39FC438"
        static let groundBeefBudget = "D77AB265-A6C3-443D-BF9E-5B06B3D04DE7"
        static let beyondSteakAndEggs = "D3CC029B-6649-4968-8AE9-FF7F758314FA"
        static let liftingBrainFog = "DD52FD95-9ECF-48D0-8075-20AC270156E7"
        static let airport = "E492149C-7ECF-4309-A394-B00D509DCED0"
        static let dairyDebate = "0A9FF5D3-9418-48D7-9D5A-0F77308D039B"
        static let elimination = "9B72198D-AB00-4670-BC28-5EDFB71D4EDC"
        static let carnivoreFlu = "012B1409-A59B-4D75-B49D-4DDC9827AF52"
        static let powerPrep = "3B2A7B80-4566-4BC5-93D9-90B08F4CA115"
        static let vitaminD = "68D96E31-91B3-49C0-96D0-6F693378A1B3"
        static let sugarSurvival = "BA4A5C9B-9EC8-4C6B-BAD5-B1A9A21A5DAB"
        static let longevity = "2F2068C1-B442-436F-A9BB-90A9D59591AD"
        static let circadian = "D198826B-EF99-44E4-9833-3785F1346F90"
        static let disasterPants = "FBE9EDA9-4998-4396-9CF0-4619924A871F"
        static let sizzleAndSlow = "139A226D-C1AD-4F16-A6A8-D6AB99062C8E"
        static let potassiumPower = "EBED89B3-43F7-445C-A8B9-31A7B4413A65"
    }

    static let weeks: [ProgramWeek] = [
        .init(number: 1, title: String(localized: "Getting started"), days: 1...7),
        .init(number: 2, title: String(localized: "Settling in"), days: 8...14),
        .init(number: 3, title: String(localized: "Building habits"), days: 15...21),
        .init(number: 4, title: String(localized: "Making it yours"), days: 22...30),
    ]

    static func week(containing day: Int) -> ProgramWeek {
        weeks.first { $0.days.contains(day) } ?? weeks[0]
    }

    static func day(_ number: Int) -> ProgramDay {
        days[min(max(number, 1), days.count) - 1]
    }

    static let safetyNote = String(localized: "Talk to your doctor before you start if you take medication for diabetes or blood pressure, are pregnant or breastfeeding, or have kidney disease. Needs can change quickly on a very low-carb diet.")

    static let disclaimer = String(localized: "General education, not medical advice.")

    static let days: [ProgramDay] = [
        // MARK: Week 1, Getting started (free)
        .init(
            number: 1,
            title: String(localized: "Keep it simple"),
            lesson: String(localized: "For the next 30 days the rules are short: eat meat, eggs and other animal foods, salt them well, drink water, and eat until you're full. Fattier cuts make this much easier than lean ones. You don't need to count anything yet."),
            task: String(localized: "Stock up on the basics: a few fatty cuts (ribeye, 80/20 ground beef, pork shoulder or chicken thighs), eggs, butter or tallow, and salt."),
            whatsNormal: String(localized: "Excitement, a few carb cravings, and feeling hungrier than you expected. Eat when you're hungry. Under-eating is the most common day-one mistake."),
            articleIds: [ArticleIds.firstWeek, ArticleIds.beginnersGuide]
        ),
        .init(
            number: 2,
            title: String(localized: "Eat until you're full"),
            lesson: String(localized: "Meat is filling, so let hunger set the amount instead of the clock. Most people settle into two or three meals a day. Big meals are fine. Snacking all day usually means your meals are too small or too lean."),
            task: String(localized: "Eat at least two full meals today, and stop when you're satisfied, not stuffed."),
            whatsNormal: String(localized: "Some people need far more food than they expected this week, and others aren't very hungry. Both settle down. Peeing more is common too: that's water leaving as your body uses up its carb stores."),
            articleIds: [ArticleIds.howToTransition, ArticleIds.satiety]
        ),
        .init(
            number: 3,
            title: String(localized: "Salt is your friend"),
            lesson: String(localized: "Cutting carbs lowers insulin, and lower insulin tells your kidneys to let go of more sodium and water. That's a big reason the first week can bring headaches and tiredness. For most healthy people the fix is simple: salt your food generously and drink when you're thirsty."),
            task: String(localized: "Salt every meal more than feels normal, and have a glass of water with a pinch of salt if a headache starts."),
            whatsNormal: String(localized: "The \"carnivore flu\" often shows up in the first week: headache, tiredness, brain fog, irritability. It's common and usually passes within a week or two. If you have high blood pressure, or heart or kidney disease, ask your doctor before adding salt."),
            articleIds: [ArticleIds.commonChallenges, ArticleIds.carnivoreFlu, ArticleIds.passTheSalt]
        ),
        .init(
            number: 4,
            title: String(localized: "Fat is fuel"),
            lesson: String(localized: "Without carbs, fat becomes your main energy source. Living on lean meat like chicken breast leaves most people tired and hungry, and lots of protein with too little fat can make you feel sick. Start with fatty cuts, or add butter or tallow to lean ones."),
            task: String(localized: "Make sure every meal today has visible fat: a fatty cut, or a spoonful of butter or tallow on top."),
            whatsNormal: String(localized: "Low energy around now is common. It usually means you need more fat, more food or more salt, and often all three."),
            articleIds: [ArticleIds.nutrition, ArticleIds.proteinToFatRatio]
        ),
        .init(
            number: 5,
            title: String(localized: "Ride out the dip"),
            lesson: String(localized: "If you feel rough today, you're right on schedule. Your body is switching from burning sugar to burning fat, and that takes time. Keep things simple: eat enough, salt well, sleep, and go easy on hard workouts for a few days."),
            task: String(localized: "Plan tomorrow's meals now, so you're never caught hungry with nothing carnivore-friendly to eat."),
            whatsNormal: String(localized: "Headaches, tiredness, crankiness and carb cravings often peak in the first several days. Muscle cramps can mean you're low on electrolytes. Chest pain, a racing heart that won't settle, or fainting are not normal: get medical help."),
            articleIds: [ArticleIds.pitfalls, ArticleIds.adaptationPhase]
        ),
        .init(
            number: 6,
            title: String(localized: "Your gut is adjusting"),
            lesson: String(localized: "Your digestion has a lot of changing to do, and it doesn't always go smoothly. Loose stools are common in the first few weeks while your body learns to handle more fat. Going less often is normal too, because meat leaves very little behind."),
            task: String(localized: "Think about how your digestion has been so far, and include it in today's check-in."),
            whatsNormal: String(localized: "Loose stools: use less added fat (butter, tallow, bacon grease), get more of your fat from the meat itself, and add the extras back slowly. Going less often without discomfort is normal. Hard or painful stools: more fat and water usually help."),
            articleIds: [ArticleIds.commonChallenges, ArticleIds.poop, ArticleIds.disasterPants]
        ),
        .init(
            number: 7,
            title: String(localized: "Look back on week one"),
            lesson: String(localized: "You made it through the hardest week. Look at your check-ins: most people feel their energy and cravings start to turn around somewhere in the first three weeks. If the scale dropped fast, much of that is water. Fat loss is slower and steadier."),
            task: String(localized: "Compare this week's check-ins with day one, and name one thing that's better and one that's harder."),
            whatsNormal: String(localized: "Feeling better than a few days ago but not great yet is typical. Getting fully used to burning fat takes several weeks, so don't judge the diet on week one."),
            articleIds: [ArticleIds.tipsForSuccess, ArticleIds.weightLoss]
        ),

        // MARK: Week 2, Settling in
        .init(
            number: 8,
            title: String(localized: "Beat the cravings"),
            lesson: String(localized: "Many cravings come from habit, not hunger: the afternoon snack, the dessert after dinner. A craving soon after a meal often means the meal was too small or too lean. Eat a bigger, fattier meal, and give the habit a replacement, like coffee or tea, a mug of bone broth, or a short walk."),
            task: String(localized: "Pick the time of day your cravings hit hardest and plan a carnivore swap for it, like bacon, a hard-boiled egg or sugar-free jerky."),
            whatsNormal: String(localized: "Sweet cravings usually fade over weeks two and three. Dreaming about bread happens, and it's nothing to worry about."),
            articleIds: [ArticleIds.sugarSurvival, ArticleIds.stayingConsistent]
        ),
        .init(
            number: 9,
            title: String(localized: "Eating out"),
            lesson: String(localized: "Almost any restaurant can feed a carnivore. Order steak, burgers without the bun, or grilled meat or fish. Ask for no sauce, extra butter, and the sides swapped for more meat or eggs. Check what's in seasonings and marinades, since they often hide sugar."),
            task: String(localized: "Pick a restaurant near you and decide what you'd order there, before you need it."),
            whatsNormal: String(localized: "Ordering differently can feel awkward at first. Most restaurants handle special requests all the time."),
            articleIds: [ArticleIds.diningOut, ArticleIds.socialFeasting]
        ),
        .init(
            number: 10,
            title: String(localized: "Sleep and energy"),
            lesson: String(localized: "Some people sleep better on carnivore right away, and others have restless nights for the first few weeks. Finishing your last meal a few hours before bed, getting morning daylight, and keeping your salt up all help. Many people notice steadier energy by now, without the after-lunch slump."),
            task: String(localized: "Finish your last meal at least three hours before bed tonight, and note how you sleep."),
            whatsNormal: String(localized: "Waking in the night or feeling wired at bedtime is common early on and usually improves. If it doesn't, try eating a little more at dinner."),
            articleIds: [ArticleIds.energy, ArticleIds.circadian]
        ),
        .init(
            number: 11,
            title: String(localized: "Keep moving"),
            lesson: String(localized: "Strength usually holds up while you adapt, but hard cardio and high-intensity workouts often dip for a few weeks while your muscles learn to run on fat. Keep training, a bit lighter, and eat enough protein to recover."),
            task: String(localized: "Take a 20 to 30 minute walk today. Easy movement helps you adapt."),
            whatsNormal: String(localized: "Feeling flat during hard workouts in the first few weeks is common. Performance usually comes back as you adapt."),
            articleIds: [ArticleIds.workouts, ArticleIds.workoutRecovery]
        ),
        .init(
            number: 12,
            title: String(localized: "Carnivore on a budget"),
            lesson: String(localized: "You don't need ribeye every night. Ground beef, chuck roast, pork shoulder, chicken thighs, eggs and organ meats are some of the cheapest nutrient-dense foods there are. Buying in bulk and freezing saves even more."),
            task: String(localized: "Price out a week of meals at your store and find your best-value cuts."),
            whatsNormal: String(localized: "Your meat bill may look higher at first, but you're no longer buying snacks, bread, sweets or sugary drinks."),
            articleIds: [ArticleIds.planShopBatchCook, ArticleIds.groundBeefBudget]
        ),
        .init(
            number: 13,
            title: String(localized: "Try organ meats"),
            lesson: String(localized: "Liver is one of the most nutrient-dense foods there is, rich in vitamin A, B12, folate and copper. A little goes a long way: a small serving once or twice a week is plenty. If the taste is a lot, mix a bit into ground beef."),
            task: String(localized: "Pick up a small amount of beef or chicken liver, or liverwurst, and try a few bites."),
            whatsNormal: String(localized: "Keep liver to small portions. Very large amounts of vitamin A can be harmful. If you're pregnant, ask your doctor about eating liver."),
            articleIds: [ArticleIds.vitaminA, ArticleIds.micronutrientDensity]
        ),
        .init(
            number: 14,
            title: String(localized: "Two weeks in"),
            lesson: String(localized: "You're halfway there. By now many people notice quieter cravings, steadier energy and hunger that's easier to read. Look at your trends and compare them with why you started."),
            task: String(localized: "Check your trends and pick one thing to adjust next week: more fat, more salt, or a new food to try."),
            whatsNormal: String(localized: "Weight loss often slows after the first week's water loss. That's expected. Judge by how your clothes fit and how you feel, not the scale from one day to the next."),
            articleIds: [ArticleIds.ditchingTheScale, ArticleIds.lowCarbWeightLoss]
        ),

        // MARK: Week 3, Building habits
        .init(
            number: 15,
            title: String(localized: "Cook once, eat three times"),
            lesson: String(localized: "Batch cooking keeps carnivore easy on busy days. Brown a big batch of ground beef, cook a roast, or boil a dozen eggs at once, and your next few meals are ready."),
            task: String(localized: "Cook one big batch of something today and portion it out for the next few days."),
            whatsNormal: String(localized: "Some people get bored around now. Switch up cuts and cooking methods rather than bringing back old foods."),
            articleIds: [ArticleIds.planShopBatchCook, ArticleIds.powerPrep, ArticleIds.mealPrepGuide]
        ),
        .init(
            number: 16,
            title: String(localized: "Cook it right"),
            lesson: String(localized: "A few methods cover almost everything: a hot cast-iron sear for steaks and burgers, low and slow for tough, cheap cuts, and the oven for big batches. Slow cooking turns fatty, tough cuts tender."),
            task: String(localized: "Try one cooking method or cut you haven't used yet."),
            whatsNormal: String(localized: "Being less hungry between meals is normal by now. There's no need to force extra meals."),
            articleIds: [ArticleIds.castIron, ArticleIds.sizzleAndSlow, ArticleIds.cookingMeat]
        ),
        .init(
            number: 17,
            title: String(localized: "Eggs and dairy"),
            lesson: String(localized: "Eggs are a staple for most carnivores. Dairy is more personal: butter and hard cheese suit many people, while milk, cream and soft cheese can cause bloating, skin flare-ups or stalled weight loss for others. If you eat dairy and aren't seeing progress, try a few weeks without it."),
            task: String(localized: "If you eat dairy, note how you feel in your check-ins on days with and without it."),
            whatsNormal: String(localized: "Bloating after milk or cream is common, since many adults don't digest lactose well."),
            articleIds: [ArticleIds.dairyDebate, ArticleIds.eggs]
        ),
        .init(
            number: 18,
            title: String(localized: "What to drink"),
            lesson: String(localized: "Water is the main drink. Many carnivores keep coffee or tea. Sweeteners, juice, soda and most alcohol work against you. Bone broth is a handy, salty drink when you want something warm."),
            task: String(localized: "Swap one drink you have out of habit for water, broth, or plain coffee or tea."),
            whatsNormal: String(localized: "Your thirst may change. Drink when you're thirsty. Pale yellow urine is a reasonable sign you're getting enough."),
            articleIds: [ArticleIds.electrolytes, ArticleIds.factsAndMyths]
        ),
        .init(
            number: 19,
            title: String(localized: "Do you need supplements?"),
            lesson: String(localized: "A varied carnivore diet covers most nutrients, especially with red meat, eggs, fish and a little organ meat. Electrolytes, meaning salt and sometimes magnesium, are the most common gap. Vitamin D depends more on sunshine than food. Talk to your doctor before starting supplements, especially if you take medication."),
            task: String(localized: "Look back at this week's meals: did they include red meat, eggs, fish and some organ meat?"),
            whatsNormal: String(localized: "Muscle cramps or twitches now can mean low magnesium or potassium. Meat has both, but some people need more."),
            articleIds: [ArticleIds.supplements, ArticleIds.magnesiumChillPill, ArticleIds.vitaminD]
        ),
        .init(
            number: 20,
            title: String(localized: "Busy days and travel"),
            lesson: String(localized: "The hardest moments are away from your kitchen. Keep easy foods on hand, like sugar-free jerky, hard-boiled eggs, canned fish, or cheese if you eat it, and know what you'd order at a gas station, an airport or a drive-through."),
            task: String(localized: "Put together a travel kit, or a backup meal you can grab without cooking."),
            whatsNormal: String(localized: "Slip-ups happen. One off-plan meal doesn't undo your progress, though your digestion may complain. Just go back to normal at your next meal."),
            articleIds: [ArticleIds.traveling, ArticleIds.airport]
        ),
        .init(
            number: 21,
            title: String(localized: "Three weeks in"),
            lesson: String(localized: "Around three weeks, many people feel adapted: steady energy, fewer cravings, a clearer head. If you're not there yet, that's okay. Some people take six weeks or more, especially if they ate a lot of sugar before."),
            task: String(localized: "Compare this week's check-ins with week one. Which one moved the most?"),
            whatsNormal: String(localized: "Mild problems that linger, like loose stools or low energy, usually respond to adjusting fat, salt or how much you eat. Anything severe, or getting worse, is worth a visit to your doctor."),
            articleIds: [ArticleIds.metabolicFlexibility, ArticleIds.mentalClarity]
        ),

        // MARK: Week 4, Making it yours
        .init(
            number: 22,
            title: String(localized: "Listen to your hunger"),
            lesson: String(localized: "After a few weeks, appetite often becomes more reliable: hungry before meals, satisfied after, and not thinking about food in between. That signal is worth trusting more than any meal schedule."),
            task: String(localized: "Before each meal today, rate your hunger from 1 to 10. Eat when it's a 6 or higher."),
            whatsNormal: String(localized: "Some days you'll be ravenous, others barely hungry. Appetite shifts with activity, sleep and, for many women, the menstrual cycle."),
            articleIds: [ArticleIds.satiety, ArticleIds.lowCarbWeightLoss]
        ),
        .init(
            number: 23,
            title: String(localized: "Meal timing and fasting"),
            lesson: String(localized: "Once you're adapted, eating twice a day, or even once, can come naturally. Let it happen if it's easy, but don't force long fasts, especially while you're still adapting or if you take medication that affects your blood sugar."),
            task: String(localized: "Notice whether you naturally want two meals today or three. Either is fine."),
            whatsNormal: String(localized: "Skipping breakfast without getting hungry is common by now. Feeling shaky, dizzy or weak when you skip a meal means you should eat."),
            articleIds: [ArticleIds.fastingStrategies]
        ),
        .init(
            number: 24,
            title: String(localized: "Know your numbers"),
            lesson: String(localized: "If you're planning to stay carnivore, it's smart to know your bloodwork. A basic panel with cholesterol, fasting glucose or A1c, and kidney and liver markers gives you and your doctor a baseline. LDL cholesterol rises noticeably for some people on carnivore, so talk your results through with your doctor rather than guessing."),
            task: String(localized: "If you haven't had bloodwork recently, ask your doctor about a baseline panel."),
            whatsNormal: String(localized: "Cholesterol numbers can shift a lot in the first months after a big diet change. That's something to discuss with your doctor, not to diagnose yourself."),
            articleIds: [ArticleIds.heart, ArticleIds.longevity]
        ),
        .init(
            number: 25,
            title: String(localized: "Find your strict version"),
            lesson: String(localized: "Some people do best on just beef, salt and water, sometimes called a \"lion diet\". Others thrive with eggs, dairy, pork, poultry and fish. If you came to carnivore for a gut, skin or autoimmune problem and it hasn't improved, a stricter few weeks can help you find what's bothering you."),
            task: String(localized: "List the animal foods you eat. Do any of them seem not to agree with you?"),
            whatsNormal: String(localized: "If one food seems to bother you, drop it for two weeks and see whether your check-ins change."),
            articleIds: [ArticleIds.elimination, ArticleIds.inflammation]
        ),
        .init(
            number: 26,
            title: String(localized: "Adding foods back"),
            lesson: String(localized: "If you want a food back, add one at a time. Eat it for a day or two, then wait a few days and watch your digestion, skin, joints, energy and sleep. If nothing changes, keep it. If something flares, set it aside."),
            task: String(localized: "If there's a food you'd like back, pick one and plan when you'll test it."),
            whatsNormal: String(localized: "After a month with little or no fiber, plant foods may upset your digestion at first. A small reaction doesn't always mean the food is bad for you."),
            articleIds: [ArticleIds.carnivoreVsKeto, ArticleIds.plantsFightBack]
        ),
        .init(
            number: 27,
            title: String(localized: "Friends, family and critics"),
            lesson: String(localized: "People will have opinions about your plate. You don't owe anyone a debate: \"I'm trying something for my health, and it's working for me\" is enough. Bring a dish to share and focus on the company."),
            task: String(localized: "Think about your next social meal and plan what you'll eat there."),
            whatsNormal: String(localized: "Feeling self-conscious about eating differently is common, and it gets easier."),
            articleIds: [ArticleIds.factsAndMyths, ArticleIds.carnivoreVsVegan, ArticleIds.socialFeasting]
        ),
        .init(
            number: 28,
            title: String(localized: "Mix it up"),
            lesson: String(localized: "Variety makes carnivore easier to stick with, and more nutritious. Rotate beef, lamb, pork, poultry, seafood and eggs. Fatty fish like salmon and sardines add omega-3s."),
            task: String(localized: "Have a protein you haven't eaten in the last month."),
            whatsNormal: String(localized: "Boredom is one of the most common reasons people quit. New cuts and recipes are the fix."),
            articleIds: [ArticleIds.beyondSteakAndEggs, ArticleIds.omega3]
        ),
        .init(
            number: 29,
            title: String(localized: "Plan month two"),
            lesson: String(localized: "Habits stick when they're easy. Think about what worked this month, like the meals you liked, the stores you used and your backup plans, and make those your defaults."),
            task: String(localized: "Write down your three go-to meals and next week's grocery list."),
            whatsNormal: String(localized: "Motivation often dips once the novelty wears off. Routines carry you when motivation doesn't."),
            articleIds: [ArticleIds.stayingConsistent, ArticleIds.stayStrong]
        ),
        .init(
            number: 30,
            title: String(localized: "You did it"),
            lesson: String(localized: "Thirty days on carnivore. Compare your check-ins from the start with where you are now, and with why you started. Whatever you decide next, you now know how your body responds."),
            task: String(localized: "Review your trends and decide what's next: keep going, go stricter, or add a food back."),
            whatsNormal: String(localized: "Many people keep improving for months, especially with gut, skin and joint problems. Keep paying attention to how you feel."),
            articleIds: [ArticleIds.carnivoreTwoPointOh, ArticleIds.advancedCarnivore]
        ),
    ]
}
