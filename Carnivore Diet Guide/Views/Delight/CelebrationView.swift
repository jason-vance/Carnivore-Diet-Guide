//
//  CelebrationView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//

import SwiftUI

/// A full-screen moment for the big wins. A ring draws itself, the badge stamps down with a sear and sparks,
/// then the words and details fade in.
struct CelebrationView<Badge: View, Details: View>: View {

    let title: String
    let message: String
    let buttonTitle: String
    /// What VoiceOver reads for the badge.
    let badgeLabel: String
    @ViewBuilder let badge: () -> Badge
    /// Laid out from the start, so nothing shifts when it fades in. `isShown` turns true as it appears.
    @ViewBuilder let details: (_ isShown: Bool) -> Details
    let onDone: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringProgress: CGFloat = 0
    @State private var showsBadge = false
    @State private var showsDetails = false
    @State private var sparks = 0

    private func play() {
        guard !reduceMotion else {
            ringProgress = 1
            showsBadge = true
            showsDetails = true
            Haptics.sear()
            return
        }
        withAnimation(.easeInOut(duration: 0.8)) { ringProgress = 1 }
        Task {
            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { showsBadge = true }
            try? await Task.sleep(for: .milliseconds(140))
            Haptics.sear()
            sparks += 1
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.easeOut(duration: 0.45)) { showsDetails = true }
        }
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()
                Ring()
                VStack(spacing: 10) {
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.text)
                        // Wraps rather than truncating "Welcome to Carnivore+" on narrow screens.
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message)
                        .font(.body)
                        .foregroundStyle(Color.text.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .multilineTextAlignment(.center)
                .opacity(showsDetails ? 1 : 0)
                .offset(y: showsDetails ? 0 : 14)

                details(showsDetails)
                    .opacity(showsDetails ? 1 : 0)
                Spacer()
                Button(action: onDone) {
                    ProgramPrimaryButtonLabel(title: buttonTitle)
                }
                .buttonStyle(.plain)
                .opacity(showsDetails ? 1 : 0)
                .disabled(!showsDetails)
            }
            .padding(24)
        }
        .onAppear(perform: play)
    }

    @ViewBuilder private func Ring() -> some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Color.accentColor.gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if showsBadge {
                badge()
                    .foregroundStyle(Color.accentColor)
                    .transition(reduceMotion ? .opacity : .stamp)
            }
        }
        .frame(width: 160, height: 160)
        // An overlay, so the sparks' bigger frame doesn't stretch the ring.
        .overlay {
            SizzleSparks(trigger: sparks, count: 28, spread: 1.3)
                .frame(width: 360, height: 360)
        }
        .accessibilityElement()
        .accessibilityLabel(Text(badgeLabel))
    }
}
