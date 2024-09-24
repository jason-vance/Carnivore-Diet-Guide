//
//  RecipeLibrary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation
import Combine

class RecipeLibrary {
    
    private typealias RecipeCache = Cache<String, RecipeCacheEntry>
    private static let cacheName = "RecipesCache"
    
    private var recipesSubject: CurrentValueSubject<Dictionary<String, Recipe>,Never> = .init([:])
    private var removedRecipeSubject: CurrentValueSubject<Recipe?, Never> = .init(nil)
    private var isLoggedIn: Bool = false
    
    public var publishedRecipesPublisher: AnyPublisher<[Recipe],Never> {
        recipesSubject
            .map {
                $0.filter { $0.value.publicationDate < .now }
                    .map { $0.value }
            }
            .eraseToAnyPublisher()
    }
    
    public var removedRecipePublisher: AnyPublisher<Recipe,Never> {
        removedRecipeSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private let authProvider: ContentAuthenticationProvider
    private let recipeCollectionFetcher: RecipeCollectionFetcher
    private let individualRecipeFetcher: IndividualRecipeFetcher
    private let resourceDeleter: ResourceDeleter
    
    private var userStateSub: AnyCancellable? = nil
    private var recipeDeletedSub: AnyCancellable? = nil

    private let recipeCache = Cache.readFromDiskOrDefault(RecipeCache.self, withName: RecipeLibrary.cacheName)
    
    private static var instance: RecipeLibrary? = nil
    public static func getInstance(
        authProvider: ContentAuthenticationProvider,
        recipeCollectionFetcher: RecipeCollectionFetcher,
        individualRecipeFetcher: IndividualRecipeFetcher,
        resourceDeleter: ResourceDeleter
    ) -> RecipeLibrary {
        if instance == nil {
            instance = .init(
                authProvider: authProvider,
                recipeCollectionFetcher: recipeCollectionFetcher,
                individualRecipeFetcher: individualRecipeFetcher,
                resourceDeleter: resourceDeleter
            )
        }
        
        return instance!
    }
    
    private var newestPublishedRecipe: Recipe? {
        recipesSubject.value
            .filter { $0.value.publicationDate < .now }
            .map { $0.value }
            .max { $0.publicationDate < $1.publicationDate }
    }
    
    private var oldestPublishedRecipe: Recipe? {
        recipesSubject.value
            .filter { $0.value.publicationDate < .now }
            .map { $0.value }
            .min { $0.publicationDate < $1.publicationDate }
    }
    
    private init(
        authProvider: ContentAuthenticationProvider,
        recipeCollectionFetcher: RecipeCollectionFetcher,
        individualRecipeFetcher: IndividualRecipeFetcher,
        resourceDeleter: ResourceDeleter
    ) {
        self.authProvider = authProvider
        self.recipeCollectionFetcher = recipeCollectionFetcher
        self.individualRecipeFetcher = individualRecipeFetcher
        self.resourceDeleter = resourceDeleter
        
        listenToUserAuthState()
        listenForDeletedRecipes()
    }
    
    private func onUpdate(authState: UserAuthState) {
        isLoggedIn = (authState == .loggedIn)
        fetchRecipes()
    }
    
    public func getRecipe(byId recipeId: String) async -> Recipe? {
        if let recipe = recipesSubject.value[recipeId] {
            return recipe
        }
        return try? await individualRecipeFetcher.fetchRecipe(withId: recipeId)
    }
    
    private func listenToUserAuthState() {
        userStateSub = authProvider.userAuthStatePublisher
            .sink(receiveValue: onUpdate(authState:))
    }
    
    private func listenForDeletedRecipes() {
        recipeDeletedSub = resourceDeleter.deletedResourcePublisher
            .filter { $0.type == .recipe }
            .sink(receiveValue: removeRecipeMatching(resource:))
    }
    
    public func resetRecipeCache() {
        recipeCache.removeAll()
        try? recipeCache.saveToDisk(withName: Self.cacheName)
        
        fetchRecipes()
    }
    
    private func removeRecipeMatching(resource: Resource) {
        let recipe = recipesSubject.value[resource.id]
        recipesSubject.value[resource.id] = nil
        recipeCache[resource.id] = nil
        removedRecipeSubject.send(recipe)
        
        try? recipeCache.saveToDisk(withName: Self.cacheName)
    }
    
    private func addToLibrary(recipes: [Recipe]) {
        recipes.forEach {
            recipesSubject.value[$0.id] = $0
            recipeCache[$0.id] = .from($0)
        }
        
        try? recipeCache.saveToDisk(withName: Self.cacheName)
    }
    
    private func fetchRecipes() {
        fetchCachedRecipes()
        
        Task {
            guard isLoggedIn else { return }
            try? await fetchNewerRecipes()
            try? await fetchOlderRecipes()
        }
    }
    
    private func fetchCachedRecipes() {
        let recipes = recipeCache.values.compactMap { $0.toRecipe() }
        recipesSubject.value = Dictionary(uniqueKeysWithValues: recipes.map{ ($0.id, $0) })
    }
    
    private func fetchNewerRecipes() async throws {
        var newestRecipe = newestPublishedRecipe
        
        var canFetchMore = true
        while canFetchMore {
            do {
                let fetchedRecipes = try await recipeCollectionFetcher.fetchRecipesOldestFirst(
                    newerThan: newestRecipe,
                    limit: 20
                )
                
                canFetchMore = !fetchedRecipes.isEmpty
                newestRecipe = fetchedRecipes.last ?? newestRecipe
                
                addToLibrary(recipes: fetchedRecipes)
                print("RecipeLibrary.fetchNewerRecipes found \(fetchedRecipes.count) recipes")
            } catch {
                print("RecipeLibrary.fetchNewerRecipes failed. \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOlderRecipes() async throws {
        var oldestRecipe = oldestPublishedRecipe
        
        var canFetchMore = true
        while canFetchMore {
            do {
                let fetchedRecipes = try await recipeCollectionFetcher.fetchRecipesNewestFirst(
                    olderThan: oldestRecipe,
                    limit: 20
                )
                
                canFetchMore = !fetchedRecipes.isEmpty
                oldestRecipe = fetchedRecipes.last ?? oldestRecipe
                
                addToLibrary(recipes: fetchedRecipes)
                print("RecipeLibrary.fetchOlderRecipes found \(fetchedRecipes.count) recipes")
            } catch {
                print("RecipeLibrary.fetchOlderRecipes failed. \(error.localizedDescription)")
            }
        }
    }
    
    func updateRecipeDataIfNecessary(_ recipe: Recipe) {
        Task {
            do {
                guard let cacheEntry = recipeCache[recipe.id] else { return }
                guard (cacheEntry.refreshAfterDate ?? .now) <= .now else { return }

                let recipe = try await individualRecipeFetcher.fetchRecipe(withId: recipe.id)

                addToLibrary(recipes: [recipe])
            } catch Resource.Errors.doesNotExist {
                print("Recipe \(recipe.id) no longer exists remotely, removing")
                removeRecipeMatching(resource: .init(recipe))
            } catch {
                print("Error updating recipe data for \(recipe.id). \(error.localizedDescription)")
            }
        }
    }
}

extension RecipeLibrary: RecipeCacheResetter {}
