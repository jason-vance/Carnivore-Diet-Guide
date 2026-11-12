//
//  NutrientLoggerPromoCard.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI

/// Suggests Nutrient Logger, the same developer's micronutrient tracker, to people reading about
/// carnivore. Tapping opens its App Store page, which Nutrient Logger's App Analytics counts under
/// Sources → App Referrer.
struct NutrientLoggerPromoCard: View {

    static let appStoreUrl = URL(string: "https://apps.apple.com/app/nutrient-logger-food-tracker/id1536557332")!

    @Environment(\.openURL) private var openURL

    /// Where the card is shown, sent with the tap event.
    let placement: String

    var body: some View {
        Button {
            iocContainer.resolve(Analytics.self)?.logNutrientLoggerPromoTapped(placement: placement)
            openURL(Self.appStoreUrl)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image("NutrientLoggerIcon")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What's your carnivore day missing?")
                            .font(.headline)
                            .foregroundStyle(Color.text)
                        Text("Nutrient Logger shows 80+ vitamins and minerals for everything you eat, and puts the ones carnivore runs short on, like vitamin C and magnesium, first.")
                            .font(.subheadline)
                            .foregroundStyle(Color.text.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack {
                    Text("From the maker of this app. Free, offline, no account.")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                    Spacer(minLength: 8)
                    Text("Get the App")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().foregroundStyle(Color.accentColor))
                }
            }
            .multilineTextAlignment(.leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(Color.accentColor, style: .init(lineWidth: 2))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        NutrientLoggerPromoCard(placement: "preview")
            .padding()
            .background(Color.background)
    }
}
