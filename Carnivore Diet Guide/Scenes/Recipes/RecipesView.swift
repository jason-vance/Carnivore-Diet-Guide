//
//  RecipesView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct RecipesView: View {
    
    @State private var navigationPath = NavigationPath()
    
    //TODO: Do I need this model?
    @StateObject private var model = RecipesViewModel()
    
    @State private var allRecipes: [Recipe] = []
    
    @State private var searchText: String = ""
    @State private var searchPresented: Bool = false
    
    private let recipeLibrary = iocContainer~>RecipeLibrary.self
    private var recipePublisher: AnyPublisher<[Recipe],Never> {
        recipeLibrary.publishedRecipesPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private var searching: Bool {
        searchPresented || !searchText.isEmpty
    }
    
    private var displayRecipes: [Recipe] {
        allRecipes.sorted { $0.publicationDate > $1.publicationDate }
    }
    
    private var filteredRecipes: [Recipe] {
        var recipes = displayRecipes
        
        let keywords = SearchKeyword.keywordsFrom(string: searchText)
        if !keywords.isEmpty {
            recipes = recipes
                .map { ($0, $0.keywords.relevanceTo(keywords)) }
                .filter { $0.1 > 0 }
                .sorted { $0.1 > $1.1 }
                .map { $0.0 }
        }
        
        return recipes
    }
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>SubscriptionLevelProvider.self)
            .subscriptionLevelPublisher
            .map { $0 == SubscriptionLevelProvider.SubscriptionLevel.none }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Recipes"))
                SearchArea()
                ScrollView {
                    if showAds { AdRow() }
                    ListContent()
                        .padding()
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.background)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
        .onReceive(recipePublisher) { allRecipes = $0 }
        .onReceive(showAdsPublisher) { showAds = $0 }
    }
    
    @ViewBuilder func SearchArea() -> some View {
        SearchBar(
            prompt: String(localized: "Entrées, Snacks, and more"),
            searchText: $searchText,
            searchPresented: $searchPresented,
            action: { }
        )
        .padding()
    }
    
    @ViewBuilder func ListContent() -> some View {
        if searching {
            SearchContent()
        } else {
            FeaturedContent()
        }
    }
    
    @ViewBuilder func SearchContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(filteredRecipes) { recipe in
                Button {
                    navigationPath.append(recipe)
                } label: {
                    RecipeItemView(recipe)
                }
            }
        }
    }
    
    @ViewBuilder func FeaturedContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(displayRecipes) { recipe in
                Button {
                    navigationPath.append(recipe)
                } label: {
                    RecipeItemView(recipe)
                }
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipesView()
    }
}
