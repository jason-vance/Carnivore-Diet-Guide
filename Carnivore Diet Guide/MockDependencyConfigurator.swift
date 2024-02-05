//
//  MockDependencyConfigurator.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation
import Swinject
import SwinjectAutoregistration

func setupMockIocContainer(_ iocContainer: Container) {
    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self, initializer: MockContentAuthenticationProvider.init)
    iocContainer.autoregister(UserOnboardingStateProvider.self, initializer: MockUserOnboardingStateProvider.init)

    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self, initializer: MockSignInAuthenticationProvider.init)

    //Recipe Library
    iocContainer.autoregister(RecipeLibraryContentProvider.self, initializer: MockRecipeLibraryContentProvider.init)
    
    //Blog Library
    iocContainer.autoregister(BlogLibraryContentProvider.self, initializer: MockBlogLibraryContentProvider.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self, initializer: MockUserProfileSignOutService.init)
    iocContainer.autoregister(UserDataProvider.self, initializer: MockUserDataProvider.init)

    //Edit User Profile
    iocContainer.autoregister(UsernameAvailabilityChecker.self, initializer: MockUsernameAvailabilityChecker.init)
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: MockCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: MockProfileImageUploader.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: MockUserDataSaver.init)
}
