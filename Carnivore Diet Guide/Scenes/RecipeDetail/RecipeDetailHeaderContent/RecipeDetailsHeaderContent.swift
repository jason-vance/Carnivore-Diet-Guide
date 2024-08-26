//
//  RecipeDetailsHeaderContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import SwiftUI
import SwinjectAutoregistration

struct RecipeDetailsHeaderContent: View {
        
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State var recipe: Recipe?
    
    @StateObject private var model = RecipeDetailsHeaderContentModel()
    @State private var showAllOptions: Bool = false
    @State private var showCommentSection: Bool = false
    
    var isInitialized: Bool {
        model.isMarkedAsFavorite != nil
    }
    
    var body: some View {
        HStack {
            CloseButton()
            Spacer()
            if let recipe = recipe {
                OptionsButtons(recipe)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .text, location: 0.8),
                .init(color: .text, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        ))
        .onChange(of: recipe, initial: true) { newRecipe in
            model.recipe = newRecipe
        }
        .sheet(isPresented: $showCommentSection) {
            if let recipe = recipe {
                CommentSectionView(resource: .init(recipe))
            }
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            HeaderButtonLabel("chevron.backward")
        }
    }
    
    @ViewBuilder func OptionsButtons(_ recipe: Recipe) -> some View {
        HStack {
            ExtraOptionsButton(recipe)
            CommentsButton()
            FavoriteButton()
        }
        .opacity(showAllOptions ? 1 : 0)
        .onChange(of: isInitialized, initial: true) { isInitialized in
            withAnimation(.snappy) {
                showAllOptions = isInitialized
            }
        }
    }
    
    @ViewBuilder func FavoriteButton() -> some View {
        Button {
            model.toggleFavorite()
        } label: {
            HeaderButtonLabel(model.isMarkedAsFavorite == true ? "heart.fill" : "heart.slash")
        }
    }
    
    @ViewBuilder func CommentsButton() -> some View {
        Button {
            showCommentSection = true
        } label: {
            HeaderButtonLabel("text.bubble.fill")
        }
    }
    
    @ViewBuilder func ExtraOptionsButton(_ recipe: Recipe) -> some View {
        Menu {
            Text(recipe.title)
            if model.recipeIsMine {
                EditRecipeButton()
                DeleteRecipeButton()
            } else {
                ReportRecipeButton()
            }
        } label: {
            HeaderButtonLabel("ellipsis")
        }
    }
    
    @ViewBuilder func ReportRecipeButton() -> some View {
        Button {
            model.reportRecipe()
        } label: {
            Label("Report", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func EditRecipeButton() -> some View {
        Button {
            //Add ability to edit recipe
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }
    
    @ViewBuilder func DeleteRecipeButton() -> some View {
        Button {
            //Add ability to delete recipe
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder func HeaderButtonLabel(_ icon: String) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(Color.accent)
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .resizable()
                .bold()
                .foregroundStyle(Color.background)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
        }
    }
}

#Preview("Succeeding Services") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeDetailView(recipeId: Recipe.sample.id)
    }
}

#Preview("Failing Services") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(RecipeFavoriter.self, argument: Recipe.self) { recipe in
            let mock = MockRecipeFavoriter(recipe: recipe)
            mock.error = "Test failure"
            return mock
        }
    } content: {
        RecipeDetailView(recipeId: Recipe.sample.id)
    }
}

#Preview("Recipe Is Mine") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(CurrentUserIdProvider.self) {
            let mock = MockCurrentUserIdProvider()
            mock.currentUserId = Recipe.sample.authorUserId
            return mock
        }
    } content: {
        RecipeDetailView(recipeId: Recipe.sample.id)
    }
}
