//
//  RecipeLibraryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI
import SwinjectAutoregistration

struct RecipeLibraryView: View {
    
    private enum LoadingState {
        case idle
        case working
    }
    
    let contentProvider = iocContainer~>RecipeLibraryContentProvider.self
    
    @State private var loadingState: LoadingState = .idle
    @State private var recipes: [Recipe] = []
    @State private var listDidAppear: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func loadRecipes() {
        Task {
            loadingState = .working
            listDidAppear = false
            do {
                recipes = try await contentProvider.loadRecipes()
            } catch {
                show(errorMessage: "Unable to load recipes: \(error.localizedDescription)")
            }
            loadingState = .idle
        }
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBarAndHeroImage()
                RecipesList()
                    .background(Color.background)
                    .clipShape(.rect(topLeadingRadius: Corners.radius, topTrailingRadius: Corners.radius))
            }
            .background(Color.background)
        }
        .onAppear {
            if recipes.isEmpty {
                loadRecipes()
            }
        }
        .alert(errorMessage, isPresented: $showError) {}
    }
    
    @ViewBuilder func TitleBarAndHeroImage() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(Color.accent)
                .frame(height: 48)
            HeroImage()
        }
        .overlay(alignment: .top) {
            TitleView()
        }
        .background(Color.accent)
    }
    
    @ViewBuilder func TitleView() -> some View {
        VStack(spacing: 0) {
            Text("Recipes")
                .font(.system(size: 48, weight: .black))
        }
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("RecipesHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipped()
            .offset(y: 16)
            .zIndex(-1)
    }
    
    @ViewBuilder func RecipesList() -> some View {
        if loadingState == .working {
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            LibraryRecipeThumbnail(recipe: recipe)
                        }
                    }
                    .offset(y: listDidAppear ? 0 : 100)
                    .opacity(listDidAppear ? 1 : 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.snappy) {
                                listDidAppear = !recipes.isEmpty
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("No Errors") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeLibraryView()
    }
}

#Preview("Loading Error") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(RecipeLibraryContentProvider.self) {
            let mock = MockRecipeLibraryContentProvider()
            mock.errorToThrow = "Didn't work"
            return mock
        }
    } content: {
        RecipeLibraryView()
    }
}
