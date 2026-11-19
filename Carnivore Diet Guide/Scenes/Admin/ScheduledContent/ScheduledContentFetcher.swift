//
//  ScheduledContentFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/18/26.
//

import Foundation

/// Articles and recipes dated in the future, which the app hides until their day.
struct ScheduledContent {
    var articles: [Article]
    var recipes: [Recipe]

    var isEmpty: Bool { articles.isEmpty && recipes.isEmpty }
}

class ScheduledContentFetcher {

    private let fetch: () async throws -> ScheduledContent

    init(fetch: @escaping () async throws -> ScheduledContent) {
        self.fetch = fetch
    }

    func fetchScheduledContent() async throws -> ScheduledContent {
        try await fetch()
    }
}

extension ScheduledContentFetcher {

    static let forTesting = ScheduledContentFetcher {
        try await Task.sleep(for: .seconds(1))
        let day: TimeInterval = 24 * 60 * 60
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let article = Article.sample
        let articles = [2, 2, 5].enumerated().map { index, days in
            Article(
                id: "scheduledArticle\(index)",
                isPremium: index != 1,
                author: article.author,
                title: index == 1 ? "Surviving the Holidays: Turkey, Ham, and Aunt Karen's Comments" : article.title,
                coverImageUrl: article.coverImageUrl,
                summary: article.summary,
                markdownContent: article.markdownContent,
                publicationDate: startOfToday.addingTimeInterval(Double(days) * day),
                categories: article.categories,
                citations: []
            )
        }
        var recipe = Recipe.longNamedSample
        recipe.publicationDate = startOfToday.addingTimeInterval(3 * day)
        return ScheduledContent(articles: articles, recipes: [recipe])
    }

    static let forTestingWithNothing = ScheduledContentFetcher {
        try await Task.sleep(for: .seconds(1))
        return ScheduledContent(articles: [], recipes: [])
    }
}
