//
//  BlogPostRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore

class FirebaseBlogPostRepository {
    
    private struct BlogPostDoc: Codable {

        struct Localization: Codable {
            static let defaultLanguage: String = "default"
            
            var language: String?
            var title: String?
            var markdownContent: String?
        }
        
        @DocumentID var id: String?
        var publicationDate: Date?
        var author: String?
        var imageUrl: String?
        var localizations: [Localization]
        
        func toBlogPost() -> BlogPost? {
            let localization: Localization? = {
                let languageCode = Locale.current.language.languageCode?.identifier
                
                if let localization = (localizations.first { $0.language == languageCode }) {
                    return localization
                } else if let localization = (localizations.first { $0.language == Localization.defaultLanguage }) {
                    return localization
                } else {
                    return localizations.first
                }
            }()
            guard let localization = localization else { return nil}
            
            guard let title = localization.title else { return nil }
            guard let imageUrl = imageUrl else { return nil }
            guard let author = author else { return nil }
            guard let publicationDate = publicationDate else { return nil }
            guard let markdownContent = localization.markdownContent else { return nil }

            return .init(
                title: title,
                imageUrl: imageUrl,
                author: author,
                markdownContent: markdownContent.replacingOccurrences(of: "\\n", with: "\n"),
                publicationDate: publicationDate
            )
        }
    }
    
    private static let BLOG_POSTS = "BlogPosts"
    private let PUBLICATION_DATE = "publicationDate"
    
    let blogPostsCollection = Firestore.firestore().collection(BLOG_POSTS)
    
    func getBlogPostsNewestToOldest(limit: Int? = nil) async throws -> [BlogPost] {
        var query = blogPostsCollection
            .order(by: PUBLICATION_DATE, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: BlogPostDoc.self).toBlogPost() }
    }
    
}
