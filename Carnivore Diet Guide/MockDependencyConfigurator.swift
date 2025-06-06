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
    iocContainer.autoregister(Analytics.self, initializer: MockAnalytics.init)
    iocContainer.autoregister(CurrentUserIdProvider.self, initializer: MockCurrentUserIdProvider.init)
    iocContainer.autoregister(LocalUserDataFetcher.self, initializer: MockLocalUserDataFetcher.init)
    iocContainer.autoregister(RemoteUserDataFetcher.self, initializer: MockRemoteUserDataFetcher.init)
    iocContainer.autoregister(UserFetcher.self, initializer: UserFetcher.init)
    iocContainer.autoregister(IsPublisherChecker.self, initializer: MockIsPublisherChecker.init)
    iocContainer.autoregister(DailyUserEngagementService.self, initializer: { DailyUserEngagementService.instance })
    iocContainer.autoregister(NotificationService.self, initializer: NotificationService.init)
    iocContainer.autoregister(SubscriptionLevelProvider.self, initializer: { SubscriptionLevelProvider.instance })
    iocContainer.autoregister(ResourceOnDeviceWasViewedFlagger.self, initializer: ResourceOnDeviceWasViewedFlagger.getInstance)

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
    
    //Article Detail
    iocContainer.autoregister(IndividualArticleFetcher.self, initializer: MockIndividualArticleFetcher.init)
    
    //Knowledge Base
    iocContainer.autoregister(ArticleCollectionFetcher.self, initializer: MockArticleCollectionFetcher.init)
    iocContainer.autoregister(ArticleLibrary.self, initializer: {
        ArticleLibrary.getInstance(
            authProvider: iocContainer~>ContentAuthenticationProvider.self,
            articleCollectionFetcher: iocContainer~>ArticleCollectionFetcher.self,
            individualArticleFetcher: iocContainer~>IndividualArticleFetcher.self,
            resourceDeleter: iocContainer~>ResourceDeleter.self
        )
    })
    iocContainer.autoregister(FeaturedArticlesFetcher.self, initializer: MockFeaturedArticlesFetcher.init)
    iocContainer.autoregister(FeaturedArticlesCache.self, initializer: FeaturedArticlesCache.getInstance)

    //Content Creation
    iocContainer.autoregister(PostImageUploader.self, initializer: MockPostImageUploader.init)
    iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forPreviewsWithSuccess })
    iocContainer.autoregister(ResourceCategoryProvider.self, initializer: MockResourceCategoryProvider.init)
    iocContainer.autoregister(ArticlePoster.self, initializer: { DefaultArticlePoster.forPreviewsWithSuccess })
    iocContainer.autoregister(PublishersFetcher.self, initializer: MockPublishersFetcher.init)
    iocContainer.autoregister(RecipePoster.self, initializer: { DefaultRecipePoster.forPreviewsWithSuccess })

    //Post Detail
    iocContainer.autoregister(PostFetcher.self, initializer: { DefaultPostFetcher.forPreviewsWithSuccess })
    
    //Recipe Detail
    iocContainer.autoregister(IndividualRecipeFetcher.self, initializer: MockIndividualRecipeFetcher.init)
    
    //Recipes
    iocContainer.autoregister(RecipeCollectionFetcher.self, initializer: MockRecipeCollectionFetcher.init)
    iocContainer.autoregister(RecipeLibrary.self, initializer: {
        RecipeLibrary.getInstance(
            authProvider: iocContainer~>ContentAuthenticationProvider.self,
            recipeCollectionFetcher: iocContainer~>RecipeCollectionFetcher.self,
            individualRecipeFetcher: iocContainer~>IndividualRecipeFetcher.self,
            resourceDeleter: iocContainer~>ResourceDeleter.self
        )
    })
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self, initializer: MockUserProfileSignOutService.init)
    iocContainer.autoregister(UserDataProvider.self, initializer: MockUserDataProvider.init)
    iocContainer.autoregister(PostCountProvider.self, initializer: MockPostCountProvider.init)
    iocContainer.autoregister(IsAdminChecker.self, initializer: MockIsAdminChecker.init)

    //Posts
    iocContainer.autoregister(PostsFetcher.self, initializer: MockPostsFetcher.init)
    iocContainer.autoregister(CurrentUsersPostsFetcher.self, initializer: { DefaultCurrentUsersPostsFetcher.instance })

    //Edit User Profile
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: MockCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: MockProfileImageUploader.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: MockUserDataSaver.init)
    iocContainer.autoregister(UsernameAvailabilityChecker.self, initializer: MockUsernameAvailabilityChecker.init)

    //Settings
    iocContainer.autoregister(UserAccountDeleter.self, initializer: MockUserAccountDeleter.init)
    iocContainer.autoregister(ArticleCacheResetter.self, initializer: { iocContainer~>ArticleLibrary.self })
    iocContainer.autoregister(RecipeCacheResetter.self, initializer: { iocContainer~>RecipeLibrary.self })

    //Comment Section
    iocContainer.autoregister(CommentProvider.self, initializer: MockCommentProvider.init)
    iocContainer.autoregister(CommentSender.self, initializer: MockCommentSender.init)
    iocContainer.autoregister(CommentDeleter.self, initializer: MockCommentDeleter.init)
    iocContainer.autoregister(CommentReporter.self, initializer: MockCommentReporter.init)
    iocContainer.autoregister(CommentCountProvider.self, initializer: MockCommentCountProvider.init)
    
    //Admin
    iocContainer.autoregister(FeaturedArticlesPoster.self, initializer: MockFeaturedArticlesPoster.init)
}
