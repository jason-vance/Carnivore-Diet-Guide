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
    //Workers
    iocContainer.autoregister(CurrentUserIdProvider.self, initializer: MockCurrentUserIdProvider.init)
    iocContainer.autoregister(UserFetcher.self, initializer: MockUserFetcher.init)
    iocContainer.autoregister(RecipeRepository.self, initializer: MockRecipeRepository.init)
    iocContainer.autoregister(ResourceCommentActivityTracker.self, initializer: DefaultResourceCommentActivityTracker.init)

    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self, initializer: MockContentAuthenticationProvider.init)
    iocContainer.autoregister(UserOnboardingStateProvider.self, initializer: MockUserOnboardingStateProvider.init)

    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self, initializer: MockSignInAuthenticationProvider.init)
    
    //Home
    iocContainer.autoregister(PopularRecipeIdFetcher.self, initializer: MockRecipePopularityFetcher.init)
    iocContainer.autoregister(FeedViewContentProvider.self) { DefaultFeedViewContentProvider.instance }
    iocContainer.autoregister(FeedItemRepository.self, initializer: MockFeedItemRepository.init)
    
    //Post Creation
    iocContainer.autoregister(PostImageUploader.self, initializer: MockPostImageUploader.init)
    iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forPreviewsWithSuccess })
    
    //Recipe Detail
    iocContainer.autoregister(RecipeFavoriter.self, argument: Recipe.self, initializer: MockRecipeFavoriter.init)
    iocContainer.autoregister(RecipeFavoriteCountProvider.self, argument: Recipe.self, initializer: MockRecipeFavoriteCountProvider.init)
    iocContainer.autoregister(RecipeCommentCountProvider.self, argument: Recipe.self, initializer: MockRecipeCommentCountProvider.init)
    iocContainer.autoregister(RecipeViewActivityTracker.self, initializer: MockRecipeViewActivityTracker.init)
    iocContainer.autoregister(RecipeReporter.self, initializer: MockRecipeReporter.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self, initializer: MockUserProfileSignOutService.init)
    iocContainer.autoregister(UserDataProvider.self, initializer: MockUserDataProvider.init)

    //Edit User Profile
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: MockCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: MockProfileImageUploader.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: MockUserDataSaver.init)
    
    //Settings
    iocContainer.autoregister(UserAccountDeleter.self, initializer: MockUserAccountDeleter.init)
    
    //Comment Section
    iocContainer.autoregister(CommentProvider.self, initializer: MockCommentProvider.init)
    iocContainer.autoregister(CommentSender.self, initializer: MockCommentSender.init)
    iocContainer.autoregister(CommentDeleter.self, initializer: MockCommentDeleter.init)
    iocContainer.autoregister(CommentReporter.self, initializer: MockCommentReporter.init)
    iocContainer.autoregister(RecipeCommentActivityTracker.self, initializer: MockRecipeCommentActivityTracker.init)
}
