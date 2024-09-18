//
//  RecipeDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import Combine
import MarkdownUI
import SwiftUI
import SwinjectAutoregistration

struct RecipeDetailView: View {
    
    private let recipeLibrary = iocContainer~>RecipeLibrary.self
    private let activityTracker = iocContainer~>ResourceViewActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var recipeId: String
    @State private var recipe: Recipe?
    @State private var isWorking: Bool = false
    
    @State private var showAds: Bool = false
    @State private var showMarketing: Bool? = nil
    @State private var showRecipeFailedToFetch: Bool = false
    @State private var showRecipeNoLongerAvailable: Bool = false
    
    private var isSubscribedPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>SubscriptionLevelProvider.self)
            .subscriptionLevelPublisher
            .receive(on: RunLoop.main)
            .map { $0 == SubscriptionLevelProvider.SubscriptionLevel.carnivorePlus }
            .eraseToAnyPublisher()
    }

    init(recipeId: String) {
        self.recipe = nil
        self.recipeId = recipeId
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.recipeId = recipe.id
    }
    
    private var thisRecipeWasRemoved: AnyPublisher<Recipe, Never> {
        recipeLibrary.removedRecipePublisher
            .receive(on: RunLoop.main)
            .filter { $0.id == recipeId }
            .eraseToAnyPublisher()
    }
    
    private func fetchRecipe(withId recipeId: String) {
        guard recipeId != recipe?.id else { return }
        
        if let recipe = recipeLibrary.getRecipe(byId: recipeId) {
            self.recipe = recipe
        } else {
            print("Recipe failed to fetch")
            showRecipeFailedToFetch = true
        }
    }

    private func markAsViewed() {
        guard let recipe = recipe else { return }
        guard let userId = userIdProvider.currentUserId else { return }
        guard recipe.author != userId else { return }
        
        Task {
            try? await activityTracker.resource(.init(recipe), wasViewedByUser: userId)
        }
    }
    
    private func updateRecipeDataIfNecessary() {
        guard let recipe = recipe else { return }
        recipeLibrary.updateRecipeDataIfNecessary(recipe)
    }

    var body: some View {
        Container()
            .navigationBarBackButtonHidden()
            .onChange(of: recipeId, initial: true) { _, newRecipeId in
                fetchRecipe(withId: newRecipeId)
            }
            .onReceive(isSubscribedPublisher) { isSubscribed in
                showAds = !isSubscribed
                showMarketing = !isSubscribed && (recipe?.isPremium == true)
            }
            .alert("The recipe could not be fetched", isPresented: $showRecipeFailedToFetch) {
                AlertOkDismissButton()
            }
            .alert("This recipe is no longer available", isPresented: $showRecipeNoLongerAvailable) {
                AlertOkDismissButton()
            }
    }
    
    @ViewBuilder func Container() -> some View {
        if showMarketing == true {
            MarketingView {
                dismiss()
            }
        } else {
            VStack(spacing: 0) {
                NavigationBar()
                if let recipe = recipe, !isWorking && showMarketing != nil {
                    ScrollView {
                        VStack(spacing: 0) {
                            if showAds { AdRow() }
                            RecipeView(recipe: recipe)
                                .onAppear { markAsViewed() }
                                .onAppear { updateRecipeDataIfNecessary() }
                                .onReceive(thisRecipeWasRemoved) { _ in
                                    isWorking = true
                                    showRecipeNoLongerAvailable = true
                                }
                                .padding(.top, showAds ? 16 : 0)
                        }
                    }
                } else {
                    LoadingView()
                }
            }
            .background(Color.background)
        }
    }
    
    @ViewBuilder func AlertOkDismissButton() -> some View {
        Button("OK", role: .cancel) {
            dismiss()
        }
    }
    
    @ViewBuilder func NavigationBar() -> some View {
        HStack {
            CloseButton()
            Spacer()
            OptionsMenu()
        }
        .padding()
        .frame(height: .barHeight)
        .overlay(alignment: .bottom) {
            BarDivider()
        }
    }
    
    @ViewBuilder func OptionsMenu() -> some View {
        if let recipe = recipe {
            let resource = Resource(recipe)
            
            HStack(spacing: 16) {
                ExtraOptionsButton(
                    resource: resource,
                    isWorking: $isWorking,
                    dismissResource: { dismiss() }
                )
                CommentButton(resource: resource)
                FavoriteButton(resource: resource)
            }
        }
    }
    
    @ViewBuilder private func LoadingView() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accentColor)
                .padding()
                .background(Color.background)
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }
}

#Preview("Default recipeId init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeDetailView(recipeId: Recipe.sample.id)
    }
}

#Preview("Default recipe init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeDetailView(recipe: .sample)
    }
}

#Preview("Fails to load") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        iocContainer.autoregister(IndividualRecipeFetcher.self) {
            let fetcher = MockIndividualRecipeFetcher()
            fetcher.error = "Test failure"
            return fetcher
        }
    } content: {
        NavigationStack {
            NavigationLink {
                RecipeDetailView(recipeId: Recipe.sample.id)
            } label: {
                HStack {
                    Text("Recipe Detail\n(Fails to Load)")
                    Image(systemName: "chevron.forward")
                }
                .foregroundStyle(Color.background)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.accent)
                }
            }
        }
    }
}
