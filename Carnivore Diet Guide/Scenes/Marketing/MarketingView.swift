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
    
    @Environment(\.presentationMode) private var presentationMode
    
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
    @State private var isPurchasing: Bool = false
    @State private var showDiscountCodeDialog = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private var displayProducts: [Product] {
        let products = limitedTimeOfferValid ? subscriptionManager.discountProducts : subscriptionManager.fullPriceProducts
        
        return products
            .map { $0.value }
            .sorted { $0.price < $1.price }
    }
    
    private var limitedTimeOfferValid: Bool {
        // 86400 seconds = 24 hours
        if let endDate = subscriptionManager.limitedTimeOfferStartDate?.addingTimeInterval(86400) {
            return endDate > .now
        }
        return false
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func doPurchase(productId: String) {
        Task {
            isPurchasing = true
            do {
                let _ = try await subscriptionManager.purchase(productId: productId)
            } catch {
                if let subError = error as? SubscriptionError {
                    errorMessage = subError.message
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
            isPurchasing = false
        }
    }
    
    private func handleOfferCodeCompletion() {
        Task {
            isPurchasing = true
            let _ = await subscriptionManager.isSubscribed()
            isPurchasing = false
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                let _ = await subscriptionManager.isSubscribed()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
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
                        FirstMonthIsFree1()
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
                    FirstMonthIsFree2()
                        .padding(.horizontal)
                    SubscribeButtons()
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
        .alert(
            "Purchase Error",
            isPresented: $showError,
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(errorMessage ?? "An unknown error occurred") }
        )
        .overlay { IsPurchasingView() }
        .onChange(of: subscriptionManager.subscriptionLevel, initial: true) { _, subscriptionLevel in
            if case .carnivorePlus = subscriptionLevel { dismiss() }
        }
        .onAppear {
            subscriptionManager.refreshProducts()
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Carnivore+") },
            leadingContent: CancelButton,
            trailingContent: { EmptyView() }
        )
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder private func IsPurchasingView() -> some View {
        if isPurchasing {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
        }
    }
    
    @ViewBuilder func Headline() -> some View {
        HStack {
            Text("Unlock the Full Carnivore Experience!")
                .font(.title)
            Spacer()
        }
    }
    
    @ViewBuilder func FirstMonthIsFree1() -> some View {
        HStack {
            Spacer()
            Text("Free for the First Month!")
                .foregroundStyle(Color.accentColor)
                .font(.headline)
                .bold(true)
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
    
    @ViewBuilder func FirstMonthIsFree2() -> some View {
        VStack {
            HStack {
                Text("The First Month is absolutely Free!")
                    .font(.headline)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func SubscribeButtons() -> some View {
        VStack {
            ForEach(displayProducts, id: \.self) { product in
                SubscribeButton(product: product)
            }
            DiscountCodeButton()
            RestoreSubscriptionButton()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private func SubscribeButton(product: Product) -> some View {
        Button {
            doPurchase(productId: product.id)
        } label: {
            HStack(spacing: 0) {
                Text(product.displayName)
                    .bold()
                Spacer()
                Text(product.displayPrice)
                    .bold()
                if let period = product.subscription?.subscriptionPeriod.unit.localizedDescription {
                    Text("/\(period.lowercased())")
                        .font(.footnote)
                }
            }
            .foregroundStyle(Color.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color.accentColor.gradient)
            }
        }
        .disabled(isPurchasing)
        .padding(.top, 8)
    }
    
    @ViewBuilder private func DiscountCodeButton() -> some View {
        Button("Enter Discount Code") {
            showDiscountCodeDialog = true
        }
        .foregroundColor(.accentColor)
        .offerCodeRedemption(isPresented: $showDiscountCodeDialog) { result in
            handleOfferCodeCompletion()
        }
        .padding(.top)
    }
    
    @ViewBuilder private func RestoreSubscriptionButton() -> some View {
        Button("Restore Subscription") {
            restorePurchases()
        }
        .foregroundColor(.accentColor)
        .padding(.top)
    }
}

#Preview {
    MarketingView()
}
