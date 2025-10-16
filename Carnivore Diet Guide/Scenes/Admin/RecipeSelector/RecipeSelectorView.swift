//
//  RecipeSelectorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct RecipeSelectorView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let saveAction: (Recipe) -> ()
    
    @State private var recipes: [Recipe] = []
    
    private let recipeLibrary = iocContainer~>RecipeLibrary.self
    
    private var recipesPublisher: AnyPublisher<[Recipe],Never> {
        recipeLibrary
            .publishedRecipesPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var displayRecipes: [Recipe] {
        recipes.sorted { $0.publicationDate > $1.publicationDate }
    }
    
    private func saveAndDismiss(recipe: Recipe) {
        saveAction(recipe)
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                ForEach(displayRecipes) { recipe in
                    RecipeRow(recipe)
                }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .onReceive(recipesPublisher) { recipes = $0 }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar("Select Recipe", leadingContent: BackButton)
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func RecipeRow(_ recipe: Recipe) -> some View {
        Button {
            saveAndDismiss(recipe: recipe)
        } label: {
            RecipeItemView(recipe)
                .recipeStyle(.horizontal)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeSelectorView { recipe in }
    }
}
