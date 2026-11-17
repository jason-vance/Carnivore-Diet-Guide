//
//  Haptics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//

import CoreHaptics
import UIKit

/// The app's haptic vocabulary, built around a hot pan. The sizzle (a quick crackle) marks finishing something,
/// and the sear (a heavy landing that crackles out) is saved for starting the program and its milestones, so it
/// keeps meaning something.
@MainActor
enum Haptics {

    /// A light tick for small changes.
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// The faint click of picking an option, like a chip.
    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Firmer the higher the number, so rating a 5 feels different from a 1.
    static func rating(_ value: Int, outOf maximum: Int = 5) {
        let fraction = Double(value - 1) / Double(max(maximum - 1, 1))
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.35 + 0.65 * min(max(fraction, 0), 1))
    }

    /// A quick crackle, like fat hitting a hot pan. For finishing something: a task or a check-in.
    static func sizzle() {
        HapticEngine.shared.play(crackle(from: 0, count: 7, peak: 0.75)) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    /// A steak landing in the pan: one heavy thump, then a crackle that dies down. For the big moments.
    static func sear() {
        HapticEngine.shared.play([.thump(at: 0, intensity: 1, sharpness: 0.3)] + crackle(from: 0.09, count: 10, peak: 0.6)) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    /// Short, sharp taps at slightly uneven intervals that fade out.
    private static func crackle(from start: TimeInterval, count: Int, peak: Float) -> [CHHapticEvent] {
        (0..<count).map { index in
            let fade = 1 - Float(index) / Float(count) * 0.65
            return .thump(
                at: start + TimeInterval(index) * 0.045 + .random(in: 0...0.018),
                intensity: peak * fade * .random(in: 0.7...1),
                sharpness: .random(in: 0.65...0.95)
            )
        }
    }
}

@MainActor
private final class HapticEngine {

    static let shared = HapticEngine()

    private var engine: CHHapticEngine?

    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = true
            engine.resetHandler = { [weak engine] in
                try? engine?.start()
            }
            self.engine = engine
        } catch {
            print("Haptics: couldn't create the engine. \(error.localizedDescription)")
        }
    }

    /// Plays `events`, or `fallback` on hardware without Core Haptics or if the pattern fails.
    func play(_ events: [CHHapticEvent], fallback: () -> Void) {
        guard let engine else {
            fallback()
            return
        }
        do {
            try engine.start()
            let player = try engine.makePlayer(with: CHHapticPattern(events: events, parameters: []))
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            fallback()
        }
    }
}

private extension CHHapticEvent {

    static func thump(at time: TimeInterval, intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
            ],
            relativeTime: time
        )
    }
}
