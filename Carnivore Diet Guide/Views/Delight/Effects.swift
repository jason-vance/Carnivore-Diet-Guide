//
//  Effects.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//
//  The hot-pan motif: sparks that pop like fat in a skillet, a stamp, and numbers that roll. Every effect here
//  skips its motion when Reduce Motion is on.
//

import SwiftUI

// MARK: Sparks

/// A quick burst of sparks from the center, like fat popping in a hot pan. Bump `trigger` to fire it.
///
/// It draws past its own edges, so give it a frame bigger than whatever it bursts from, usually in an overlay.
struct SizzleSparks: View {

    let trigger: Int
    var count = 16
    /// How far the sparks fly. 1 suits a big moment; smaller fits a button.
    var spread: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startedAt: Date?
    @State private var particles: [Particle] = []

    private static let duration: TimeInterval = 0.7
    /// The app's red and a hot amber, alternating.
    private static let colors: [Color] = [Color.accentColor, Color(red: 0.96, green: 0.56, blue: 0.18)]

    private struct Particle {
        let angle: Double
        let speed: Double
        let size: Double
        let color: Color
    }

    var body: some View {
        TimelineView(.animation(paused: startedAt == nil)) { context in
            Canvas { canvas, size in
                guard let startedAt else { return }
                let elapsed = context.date.timeIntervalSince(startedAt)
                guard elapsed < Self.duration else { return }
                let progress = elapsed / Self.duration
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                canvas.opacity = 1 - progress * progress
                for particle in particles {
                    // Fast out, then slowing, with a little gravity so they arc down.
                    let distance = particle.speed * spread * (1 - pow(1 - progress, 2)) * Self.duration
                    let x = center.x + cos(particle.angle) * distance
                    let y = center.y + sin(particle.angle) * distance + 90 * spread * elapsed * elapsed
                    let size = particle.size * (1 - progress * 0.6)
                    canvas.fill(Path(ellipseIn: CGRect(x: x - size / 2, y: y - size / 2, width: size, height: size)), with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: trigger) { _, _ in
            guard !reduceMotion else { return }
            particles = (0..<count).map { index in
                Particle(
                    angle: Double(index) / Double(count) * 2 * .pi + .random(in: -0.3...0.3),
                    speed: .random(in: 90...170),
                    size: .random(in: 2.5...5),
                    color: Self.colors[index % Self.colors.count]
                )
            }
            let start = Date.now
            startedAt = start
            Task {
                try? await Task.sleep(for: .seconds(Self.duration))
                if startedAt == start {
                    startedAt = nil
                }
            }
        }
    }
}

// MARK: Pressable

/// For cards: they give a little under your thumb, shrinking slightly while pressed and springing back.
/// Content without its own color takes the tint, as with a default button.
struct PressableButtonStyle: ButtonStyle {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.tint)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}

// MARK: Stamp

private struct StampModifier: ViewModifier {
    let scale: CGFloat
    let opacity: Double
    let rotation: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
    }
}

extension AnyTransition {
    /// Drops in big and tilted, then lands. Pair it with a springy animation.
    static var stamp: AnyTransition {
        .modifier(
            active: StampModifier(scale: 2.2, opacity: 0, rotation: -14),
            identity: StampModifier(scale: 1, opacity: 1, rotation: 0)
        )
    }
}

// MARK: Numbers

/// A number that rolls up from zero when it appears, and rolls again when it changes.
struct RollingNumber: View {

    let value: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = 0

    var body: some View {
        Text("\(shown)")
            .contentTransition(.numericText(value: Double(shown)))
            .onAppear {
                guard !reduceMotion else {
                    shown = value
                    return
                }
                withAnimation(.snappy(duration: 0.6).delay(0.15)) { shown = value }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.snappy) { shown = newValue }
            }
            .accessibilityLabel(Text("\(value)"))
    }
}
