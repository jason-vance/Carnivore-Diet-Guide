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
    
    //Blog Library
    iocContainer.autoregister(BlogLibraryContentProvider.self, initializer: FirebaseBlogLibraryContentProvider.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self) { FirebaseAuthenticationProvider.instance }
    //TODO: Make a FirebaseUserProfileDataProvider
    iocContainer.autoregister(UserProfileDataProvider.self, initializer: MockUserProfileDataProvider.init)

    //Edit User Profile
    //TODO: Make a FirebaseProfileFormUsernameAvailabilityChecker
    iocContainer.autoregister(ProfileFormUsernameAvailabilityChecker.self, initializer: MockProfileFormUsernameAvailabilityChecker.init)
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: FirebaseCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: FirebaseProfileImageUploader.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: FirebaseUserRepository.init)
}
