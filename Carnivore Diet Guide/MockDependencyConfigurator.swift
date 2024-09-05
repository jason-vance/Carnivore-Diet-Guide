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
    
    //Resources
    iocContainer.autoregister(ResourceFavoriter.self, initializer: { ResourceFavoriter.forPreviews })
    iocContainer.autoregister(FavoriteCountProvider.self, initializer: MockFavoriteCountProvider.init)
    iocContainer.autoregister(ResourceReporter.self, initializer: MockResourceReporter.init)
    iocContainer.autoregister(ResourceDeleter.self, initializer: MockResourceDeleter.getInstance)
    iocContainer.autoregister(ResourceCreatedActivityTracker.self, initializer: MockResourceCreatedActivityTracker.init)
    iocContainer.autoregister(ResourceViewActivityTracker.self, initializer: MockResourceViewActivityTracker.init)
    iocContainer.autoregister(ResourceFavoriteActivityTracker.self, initializer: MockResourceFavoriteActivityTracker.init)
    iocContainer.autoregister(ResourceCommentActivityTracker.self, initializer: MockResourceCommentActivityTracker.init)

    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self, initializer: MockContentAuthenticationProvider.init)
    iocContainer.autoregister(UserOnboardingStateProvider.self, initializer: MockUserOnboardingStateProvider.init)

    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self, initializer: MockSignInAuthenticationProvider.init)
    
    //Home
    iocContainer.autoregister(PopularResourceIdFetcher.self, initializer: MockRecipePopularityFetcher.init)
    iocContainer.autoregister(FeedViewContentProvider.self) { DefaultFeedViewContentProvider.instance }
    iocContainer.autoregister(FeedItemRepository.self, initializer: MockFeedItemRepository.init)
    
    //Knowledge Base
    iocContainer.autoregister(ArticleFetcher.self, initializer: MockArticleFetcher.init)
    ArticleLibrary.makeInstance(articleFetcher: iocContainer~>ArticleFetcher.self)
    iocContainer.autoregister(ArticleLibrary.self, initializer: { ArticleLibrary.instance })

    //Content Creation
    iocContainer.autoregister(PostImageUploader.self, initializer: MockPostImageUploader.init)
    iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forPreviewsWithSuccess })
    iocContainer.autoregister(ResourceCategoryProvider.self, initializer: MockResourceCategoryProvider.init)
    iocContainer.autoregister(ArticlePoster.self, initializer: { DefaultArticlePoster.forPreviewsWithSuccess })
    
    //Article Detail
    iocContainer.autoregister(ArticleDetailArticleFetcher.self, initializer: MockArticleDetailArticleFetcher.init)
    
    //Post Detail
    iocContainer.autoregister(PostFetcher.self, initializer: { DefaultPostFetcher.forPreviewsWithSuccess })
    
    //Recipe Detail
    iocContainer.autoregister(RecipeFavoriter.self, argument: Recipe.self, initializer: MockRecipeFavoriter.init)
    iocContainer.autoregister(RecipeFavoriteCountProvider.self, argument: Recipe.self, initializer: MockRecipeFavoriteCountProvider.init)
    iocContainer.autoregister(RecipeCommentCountProvider.self, argument: Recipe.self, initializer: MockRecipeCommentCountProvider.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self, initializer: MockUserProfileSignOutService.init)
    iocContainer.autoregister(UserDataProvider.self, initializer: MockUserDataProvider.init)
    iocContainer.autoregister(PostCountProvider.self, initializer: MockPostCountProvider.init)
    
    //Posts
    iocContainer.autoregister(PostsFetcher.self, initializer: MockPostsFetcher.init)

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
    iocContainer.autoregister(CommentCountProvider.self, initializer: MockCommentCountProvider.init)
}
