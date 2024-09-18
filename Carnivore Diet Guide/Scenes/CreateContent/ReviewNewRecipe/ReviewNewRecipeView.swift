//
//  ReviewNewRecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ReviewNewRecipeView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let recipePoster = iocContainer~>RecipePoster.self
    private let activityTracker = iocContainer~>ResourceCreatedActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    public let newRecipeData: NewRecipeData
    public let dismissAll: () -> ()
    
    @State private var isPosting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var feedItem: FeedItem {
        FeedItem(
            id: UUID().uuidString,
            publicationDate: newRecipeData.metadata.publicationDate,
            type: .recipe,
            resourceId: newRecipeData.data.id.uuidString,
            userId: newRecipeData.data.userId,
            imageUrls: newRecipeData.data.imageUrls,
            title: newRecipeData.data.title,
            summary: newRecipeData.metadata.summary.text
        )
    }
    
    private var recipe: Recipe {
        Recipe(
            id: newRecipeData.data.id.uuidString,
            isPremium: true,
            author: newRecipeData.data.userId,
            title: newRecipeData.data.title,
            coverImageUrl: newRecipeData.data.imageUrls[0],
            summary: newRecipeData.metadata.summary,
            prepTimeMinutes: newRecipeData.metadata.prepTimeMinutes,
            cookTimeMinutes: newRecipeData.metadata.cookTimeMinutes,
            servings: newRecipeData.metadata.servings,
            difficultyLevel: newRecipeData.metadata.difficultyLevel,
            markdownContent: newRecipeData.data.markdownContent,
            publicationDate: newRecipeData.metadata.publicationDate,
            basicNutritionInfo: newRecipeData.metadata.basicNutritionInfo
        )
    }
    
    private func goBack() {
        dismiss()
    }
    
    private func addCreatedActivity() {
        guard let userId = userIdProvider.currentUserId else { return }
        Task {
            try? await activityTracker.resource(.init(recipe), wasCreatedByUser: userId)
        }
    }
    
    private func postAndDismiss() {
        Task {
            do {
                withAnimation(.snappy) { isPosting = true }
                try await recipePoster.post(recipe: recipe, feedItem: feedItem)
                addCreatedActivity()
                dismissAll()
            } catch {
                withAnimation(.snappy) { isPosting = false }
                show(alert: "Failed to post. Please try again later.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Review Your Recipe"))
            ScrollView {
                VStack {
                    VStack {
                        ReviewContentSectionHeader(String(localized: "As seen in the Community Feed"))
                        FeedItemView(feedItem: feedItem)
                        ReviewContentSectionHeader(String(localized: "As seen in Recipes"))
                        RecipesViews()
                        ReviewContentSectionHeader(String(localized: "As seen while reading"))
                    }
                    .padding(.horizontal, .itemHorizontalPadding)
                    RecipeView(recipe: recipe)
                }
                .padding(.bottom, .barHeight)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
        .overlay(alignment: .bottom) {
            BottomControls()
        }
        .overlay {
            ProgressSpinner()
        }
        .navigationBarBackButtonHidden()
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func ProgressSpinner() -> some View {
        if isPosting {
            ProgressSpinnerOverlay()
        }
    }
    
    @ViewBuilder func BottomControls() -> some View {
        if !isPosting {
            ReviewContentBottomControls(
                editAction: goBack,
                approvedAction: postAndDismiss
            )
        }
    }
    
    @ViewBuilder func RecipesViews() -> some View {
        VStack {
            RecipeItemView(recipe)
                .recipeStyle(.largeVertical)
            HStack {
                RecipeItemView(recipe)
                    .recipeStyle(.vertical)
                RecipeItemView(recipe)
                    .recipeStyle(.vertical)
            }
            RecipeItemView(recipe)
                .recipeStyle(.horizontal)
        }
    }
}

#Preview("Fails") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(RecipePoster.self) {
            DefaultRecipePoster.forPreviewsWithFailure
        }
    } content: {
        ReviewNewRecipeView(newRecipeData: .sample) {}
    }
}
