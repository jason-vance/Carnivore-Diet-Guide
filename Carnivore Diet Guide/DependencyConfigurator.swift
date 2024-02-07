//
//  DependencyConfigurator.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation
import Swinject
import SwinjectAutoregistration

let iocContainer: Container = {
    let container = Container()
    setup(iocContainer: container)
    return container
}()

fileprivate func setup(iocContainer: Container) {
    //Workers
    iocContainer.autoregister(FirebaseAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(CurrentUserIdProvider.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(UserDataProvider.self, initializer: FirestoreUserDataProvider.init)
    iocContainer.autoregister(FirebaseUserRepository.self, initializer: FirebaseUserRepository.init)

    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(UserOnboardingStateProvider.self, initializer: DefaultUserOnboardingStateProvider.init)

    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }

    //Home
    iocContainer.autoregister(HomeViewContentProvider.self, initializer: FirebaseHomeViewContentProvider.init)
    
    //Recipe Library
    iocContainer.autoregister(RecipeLibraryContentProvider.self, initializer: FirebaseRecipeLibraryContentProvider.init)
    
    //Recipe Detail
    iocContainer.autoregister(RecipeFavoriter.self, argument: Recipe.self, initializer: DefaultRecipeFavoriter.init)
    iocContainer.autoregister(FavoriteRecipeRepo.self, initializer: FirebaseUserRepository.init)
    iocContainer.autoregister(RecipeFavoritersRepo.self, initializer: FirebaseRecipeRepository.init)
    iocContainer.autoregister(RecipeFavoriteCountProvider.self, argument: Recipe.self, initializer: DefaultRecipeFavoriteCountProvider.init)

    //Knowledge Library
    iocContainer.autoregister(KnowledgeLibraryContentProvider.self, initializer: FirebaseKnowledgeLibraryContentProvider.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(UserDataProvider.self, initializer: FirestoreUserDataProvider.init)

    //Edit User Profile
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: FirebaseCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: FirebaseProfileImageStorage.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: FirebaseUserRepository.init)
    
    //Settings
    iocContainer.autoregister(UserAccountDeleter.self, initializer: FirebaseUserAccountDeleter.init)
}
