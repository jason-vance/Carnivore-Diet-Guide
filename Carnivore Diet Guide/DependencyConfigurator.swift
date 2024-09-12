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
    iocContainer.autoregister(UserFetcher.self, initializer: FirebaseUserRepository.init)
    iocContainer.autoregister(RecipeRepository.self, initializer: FirebaseRecipeRepository.init)
    iocContainer.autoregister(IsPublisherChecker.self, initializer: FirebasePublishersRepository.init)
    iocContainer.autoregister(DailyUserEngagementService.self, initializer: { DailyUserEngagementService.instance })
    iocContainer.autoregister(NotificationService.self, initializer: NotificationService.init)

    //Resources
    iocContainer.autoregister(ResourceFavoriter.self, initializer: { ResourceFavoriter.forProd })
    iocContainer.autoregister(FavoriteCountProvider.self, initializer: FirebaseFavoriteCountProvider.init)
    iocContainer.autoregister(ResourceReporter.self, initializer: FirebaseReportRepository.init)
    iocContainer.autoregister(ResourceDeleter.self, initializer: FirebaseResourceDeleter.getInstance)
    iocContainer.autoregister(ResourceCreatedActivityTracker.self, initializer: FirebaseResourceActivityRepository.init)
    iocContainer.autoregister(ResourceViewActivityTracker.self, initializer: FirebaseResourceActivityRepository.init)
    iocContainer.autoregister(ResourceFavoriteActivityTracker.self, initializer: FirebaseResourceActivityRepository.init)
    iocContainer.autoregister(ResourceCommentActivityTracker.self, initializer: FirebaseResourceActivityRepository.init)

    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(UserOnboardingStateProvider.self, initializer: DefaultUserOnboardingStateProvider.init)

    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }

    //Home
    iocContainer.autoregister(PopularResourceIdFetcher.self, initializer: FirebaseResourceActivityRepository.init)
    iocContainer.autoregister(FeedViewContentProvider.self) { DefaultFeedViewContentProvider.instance }
    iocContainer.autoregister(FeedItemRepository.self, initializer: FirebaseFeedItemRepository.init)
    
    //Article Detail
    iocContainer.autoregister(IndividualArticleFetcher.self, initializer: FirebaseArticleRepository.init)
    
    //Knowledge Base
    iocContainer.autoregister(ArticleCollectionFetcher.self, initializer: FirebaseArticleRepository.init)
    ArticleLibrary.makeInstance(
        authProvider: iocContainer~>ContentAuthenticationProvider.self,
        articleCollectionFetcher: iocContainer~>ArticleCollectionFetcher.self,
        individualArticleFetcher: iocContainer~>IndividualArticleFetcher.self,
        resourceDeleter: iocContainer~>ResourceDeleter.self
    )
    iocContainer.autoregister(ArticleLibrary.self, initializer: { ArticleLibrary.instance })
    iocContainer.autoregister(FeaturedArticlesFetcher.self, initializer: FirebaseFeaturedArticlesRepository.init)

    //Content Creation
    iocContainer.autoregister(PostImageUploader.self, initializer: FirebasePostImageStorage.init)
    iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forProd })
    iocContainer.autoregister(ResourceCategoryProvider.self, initializer: FirebaseResourceCategoryRepository.init)
    iocContainer.autoregister(ArticlePoster.self, initializer: { DefaultArticlePoster.forProd })
    iocContainer.autoregister(PublishersFetcher.self, initializer: FirebasePublishersRepository.init)

    //Post Detail
    iocContainer.autoregister(PostFetcher.self, initializer: { DefaultPostFetcher.forProd })

    //Recipe Detail
    iocContainer.autoregister(RecipeFavoriter.self, argument: Recipe.self, initializer: DefaultRecipeFavoriter.init)
    iocContainer.autoregister(FavoriteRecipeRepo.self, initializer: FirebaseUserRepository.init)
    iocContainer.autoregister(RecipeFavoritersRepo.self, initializer: FirebaseRecipeRepository.init)
    iocContainer.autoregister(RecipeCommentsRepo.self, initializer: FirebaseRecipeRepository.init)
    iocContainer.autoregister(RecipeFavoriteCountProvider.self, argument: Recipe.self, initializer: DefaultRecipeFavoriteCountProvider.init)
    iocContainer.autoregister(RecipeCommentCountProvider.self, argument: Recipe.self, initializer: DefaultRecipeCommentCountProvider.init)
    
    //User Profile
    iocContainer.autoregister(UserProfileSignOutService.self) { FirebaseAuthenticationProvider.instance }
    iocContainer.autoregister(UserDataProvider.self, initializer: FirestoreUserDataProvider.init)
    iocContainer.autoregister(PostCountProvider.self, initializer: FirebasePostRepository.init)
    iocContainer.autoregister(IsAdminChecker.self, initializer: FirebaseAdminRepository.init)

    //Posts
    iocContainer.autoregister(PostsFetcher.self, initializer: FirebasePostRepository.init)
    iocContainer.autoregister(CurrentUsersPostsFetcher.self, initializer: { DefaultCurrentUsersPostsFetcher.instance })

    //Edit User Profile
    iocContainer.autoregister(CurrentUserDataProvider.self, initializer: FirebaseCurrentUserDataProvider.init)
    iocContainer.autoregister(ProfileImageUploader.self, initializer: FirebaseProfileImageStorage.init)
    iocContainer.autoregister(UserDataSaver.self, initializer: FirebaseUserRepository.init)
    
    //Settings
    iocContainer.autoregister(UserAccountDeleter.self, initializer: FirebaseUserAccountDeleter.init)
    iocContainer.autoregister(ArticleCacheResetter.self, initializer: { ArticleLibrary.instance })

    //Comment Section
    iocContainer.autoregister(CommentProvider.self, initializer: FirebaseCommentRepository.init)
    iocContainer.autoregister(CommentSender.self, initializer: FirebaseCommentRepository.init)
    iocContainer.autoregister(CommentDeleter.self, initializer: FirebaseCommentRepository.init)
    iocContainer.autoregister(CommentReporter.self, initializer: FirebaseReportRepository.init)
    iocContainer.autoregister(CommentCountProvider.self, initializer: FirebaseCommentCountProvider.init)
    
    //Admin
    iocContainer.autoregister(FeaturedArticlesPoster.self, initializer: FirebaseFeaturedArticlesRepository.init)
}
