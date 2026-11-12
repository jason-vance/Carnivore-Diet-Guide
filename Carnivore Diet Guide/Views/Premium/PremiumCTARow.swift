//
//  PremiumCTARow.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// A "go premium" row that opens the Carnivore+ paywall. It renders nothing for subscribers,
/// so call sites can place it unconditionally. Matches Nutrient Logger's PremiumCTARow.
struct PremiumCTARow: View {

    let placement: PremiumCTAPlacement
    let size: PremiumCTASize

    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self

    @State private var showMarketingView = false

    private var teaser: String {
        switch placement {
        case .featuredArticles:
            return String(localized: "Unlock every premium article and recipe")
        case .articleList, .articleDetail:
            return String(localized: "Unlock every premium article")
        case .recipes, .recipeDetail:
            return String(localized: "Unlock every premium recipe")
        case .profile:
            return String(localized: "Get more with Carnivore+")
        }
    }

    var body: some View {
        if subscriptionManager.subscriptionLevel != .carnivorePlus {
            Button {
                iocContainer.resolve(Analytics.self)?.logPremiumCTATapped(placement: placement)
                showMarketingView = true
            } label: {
                content
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $showMarketingView) {
                MarketingView()
            }
        }
    }

    @ViewBuilder private var content: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(teaser)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.text)
                    .multilineTextAlignment(.leading)
                if size == .medium {
                    Text("Tap to see what's included")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.text.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, size == .medium ? 16 : 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color.accentColor.opacity(0.12))
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        VStack(spacing: 16) {
            PremiumCTARow(placement: .featuredArticles, size: .medium)
            PremiumCTARow(placement: .recipeDetail, size: .small)
        }
        .padding()
        .background(Color.background)
    }
}
