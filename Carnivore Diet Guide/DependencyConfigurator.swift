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
    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }
    //TODO: Make a FirebaseContentUserOnboardingStateProvider
    iocContainer.autoregister(ContentUserOnboardingStateProvider.self, initializer: MockContentUserOnboardingStateProvider.init)

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
    
    //Edit User Profile
    //TODO: Make a FirebaseProfileFormUsernameAvailabilityChecker
    iocContainer.autoregister(ProfileFormUsernameAvailabilityChecker.self, initializer: MockProfileFormUsernameAvailabilityChecker.init)
    //TODO: Make a FirebaseUserProfileDataProvider
    iocContainer.autoregister(UserProfileDataProvider.self, initializer: MockUserProfileDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: FirebaseProfileImageUploader.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: FirebaseUserRepository.init)
}
