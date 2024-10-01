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
    
    private let showcaseArticleIds: [String] = [
        "41F4B6E8-534E-4B45-81F1-D7C29F58C168",
        "159AAB77-225A-4AFF-9F26-9CFE0B8132CF",
        "56A9D06C-1121-4C5A-9755-7C4B538EA7DD"
    ]
    private let showcaseRecipeIds: [String] = [
        "0F2B8F14-1D3D-4C7F-B07C-4AAFE6479F5A",
        "31FAE98F-F20B-40D7-A6F6-427EB7729E30",
        "3784988C-7396-49E2-900B-39FC977F997C"
    ]
    
    @State private var showcaseArticles: [Article] = []
    @State private var showcaseRecipes: [Recipe] = []
    @State private var isWorking: Bool = false
    @State private var showBuiltInRestoreButton: Bool = false
    
    func fetchShowcaseResources() {
        Task {
            guard let articleLibrary = iocContainer.resolve(ArticleLibrary.self) else { return }
            guard let recipeLibrary = iocContainer.resolve(RecipeLibrary.self) else { return }
            
            var articles: [Article] = []
            for articleId in showcaseArticleIds {
                guard let article = await articleLibrary.getArticle(byId: articleId) else { continue }
                articles.append(article)
            }
            self.showcaseArticles = articles
            
            var recipes: [Recipe] = []
            for recipeId in showcaseRecipeIds {
                guard let recipe = await recipeLibrary.getRecipe(byId: recipeId) else { continue }
                recipes.append(recipe)
            }
            self.showcaseRecipes = recipes
        }
    }
    
    private func logScreenView() {
        guard let analytics = iocContainer.resolve(Analytics.self) else { return }
        analytics.logScreenView(screenName: "RecipeDetailView", screenClass: RecipeDetailView.self)
    }

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
        .onAppear { fetchShowcaseResources() }
        .onAppear { logScreenView() }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Carnivore+") },
            leadingContent: CancelButton,
            trailingContent: WorkingIndicator
        )
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            cancel()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func WorkingIndicator() -> some View {
        if isWorking {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accent)
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
                    ForEach(showcaseArticles) { article in
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
                    ForEach(showcaseRecipes) { recipe in
                        RecipeItemView(recipe)
                            .recipeStyle(.largeVertical)
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
        VStack(spacing: 0) {
            SubscriptionStoreView(groupID: subscriptionManager.carnivorePlusSubscriptionGroupId) {
                Image("steak")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
                    .padding(.horizontal)
            }
            .onInAppPurchaseStart { _ in
                withAnimation(.snappy) { isWorking = true }
            }
            .onInAppPurchaseCompletion { product, purchaseResult in
                withAnimation(.snappy) { isWorking = false }
                if case .success(.success(let verificationResult)) = purchaseResult {
                    subscriptionManager.handle(transactionUpdate: verificationResult)
                }
            }
            .storeButton(showBuiltInRestoreButton ? .visible : .hidden, for: .restorePurchases)
            .subscriptionStoreControlStyle(.picker)
            .preferredColorScheme(.light)
            if !showBuiltInRestoreButton {
                Button {
                    subscriptionManager.checkSubscriptionStatus()
                    withAnimation(.snappy) { showBuiltInRestoreButton = true }
                } label: {
                    Text("Restore Subscription")
                        .foregroundStyle(Color.accent)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    MarketingView { }
}
