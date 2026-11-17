//
//  CarnivorePlusWelcomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//

import SwiftUI

/// The celebration right after someone subscribes: the Carnivore+ sparkles stamp down, then what they've
/// unlocked checks off one by one.
struct CarnivorePlusWelcomeView: View {

    let onDone: () -> Void

    private let perks = [
        String(localized: "All 30 days of the program"),
        String(localized: "Every premium article and recipe"),
        String(localized: "Your own trackers in check-ins"),
    ]

    var body: some View {
        CelebrationView(
            title: String(localized: "Welcome to Carnivore+"),
            message: String(localized: "Everything is unlocked. Thank you for supporting the Carnivore Diet Guide."),
            buttonTitle: String(localized: "Let's Go"),
            badgeLabel: String(localized: "Carnivore+"),
            badge: {
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .bold))
            },
            details: { isShown in
                Perks(isShown: isShown)
            },
            onDone: onDone
        )
    }

    @ViewBuilder private func Perks(isShown: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(perks.enumerated()), id: \.offset) { index, perk in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                        .scaleEffect(isShown ? 1 : 0.3)
                        .opacity(isShown ? 1 : 0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.55).delay(0.3 + Double(index) * 0.18), value: isShown)
                    Text(perk)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .foregroundStyle(Color.text.opacity(0.06))
        }
    }
}

#Preview {
    CarnivorePlusWelcomeView { }
}
