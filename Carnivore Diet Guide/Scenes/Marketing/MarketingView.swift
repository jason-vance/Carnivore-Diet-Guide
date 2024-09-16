//
//  MarketingView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/14/24.
//

import SwiftUI
import MarkdownUI
import StoreKit
import SwinjectAutoregistration

struct MarketingView: View {
    
    let cancel: () -> ()
    
    private let subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    
    @Environment(\.purchase) private var purchase: PurchaseAction
    @State private var product: Product? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    VStack {
                        Headline()
                        Subheadline()
                        SubSubheadline()
                    }
                    .padding(.horizontal)
                    AdFreeExperience()
                        .padding(.horizontal)
                    ExclusiveArticles()
                    PremiumRecipes()
                    AdvancedProgressTracking()
                        .padding(.horizontal)
                    SubscribeButton()
                }
                .foregroundStyle(Color.text)
                .padding(.vertical)
            }
            .background {
                ZStack(alignment: .top) {
                    Circle()
                        .foregroundStyle(Color.accent.opacity(0.1))
                        .offset(x: -175, y: -150)
                    Circle()
                        .foregroundStyle(Color.text.opacity(0.1))
                        .offset(x: 150, y: 250)
                }
            }
        }
        .background(Color.background)
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            "Carnivore+",
            leadingContent: CancelButton
        )
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            cancel()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func Headline() -> some View {
        HStack {
            Text("Unlock the Full Carnivore Experience!")
                .font(.title)
            Spacer()
        }
    }
    
    @ViewBuilder func Subheadline() -> some View {
        HStack {
            Text("Get exclusive access to premium content and tools designed to help you achieve your health goals faster.")
                .font(.headline)
            Spacer()
        }
    }
    
    @ViewBuilder func SubSubheadline() -> some View {
        HStack {
            Text("And all for less than the price of a pound of ground beef!")
                .font(.body)
            Spacer()
        }
    }
    
    @ViewBuilder func AdFreeExperience() -> some View {
        VStack {
            HStack {
                Text("Ad-Free Experience")
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("No interruptions! Enjoy a seamless, ad-free experience for focused learning and community interaction. For about the same price as a pound of butter!")
                    .font(.body)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func ExclusiveArticles() -> some View {
        VStack {
            HStack {
                Text("Exclusive Articles & Guides")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("In-depth resources not available to free users. Get insights and tips from experts to optimize your health journey! For less than half the price of steak!")
                    .font(.body)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    //TODO: Get real articles to show off, maybe the three most popular premium ones
                    ForEach([Article.sample, Article.sample2]) { article in
                        ArticleItemView(article)
                            .articleStyle(.largeVertical)
                            .containerRelativeFrame(.horizontal) { length, axis in
                                length * 0.75
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 8)
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .listRowInsets(EdgeInsets())    // Must be last or scrollContent margins will be messed up
        }
    }
    
    @ViewBuilder func PremiumRecipes() -> some View {
        VStack {
            HStack {
                Text("Premium Recipes")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("Access to an expanded collection of carnivore diet recipes! (Even as good as a seared ribeye is, you probably shouldn't eat that for every meal)")
                    .font(.body)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    //TODO: Get real recipes to show off, maybe the three most popular premium ones
                    ForEach(Recipe.samples) { recipe in
                        VStack {
                            Text(recipe.title)
                                Spacer()
                        }
                        .padding()
                        .frame(height: 100)
                        .containerRelativeFrame(.horizontal) { length, axis in
                            length * 0.75
                        }
                        .background(Color.background)
                        .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
                        .shadow(color: Color.text, radius: 4)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 8)
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .listRowInsets(EdgeInsets())    // Must be last or scrollContent margins will be messed up
        }
    }
    
    @ViewBuilder func AdvancedProgressTracking() -> some View {
        VStack {
            HStack {
                Text("Advanced Progress Tracking")
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("Enhanced tools to monitor your health metrics and progress. Coming soon!")
                    .font(.body)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func SubscribeButton() -> some View {
        SubscriptionStoreView(groupID: subscriptionManager.carnivorePlusSubscriptionGroupId) {
            Image("steak")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
                .padding(.horizontal)
        }
        .onInAppPurchaseCompletion { product, purchaseResult in
            if case .success(.success(let verificationResult)) = purchaseResult {
                switch verificationResult {
                case .verified(let transaction):
                    subscriptionManager.handle(verifiedTransaction: transaction)
                case .unverified(let transaction, let error):
                    subscriptionManager.handle(unverifiedTransaction: transaction, withError: error)
                }
            }
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.picker)
        .preferredColorScheme(.light)
    }
}

#Preview {
    MarketingView { }
}
