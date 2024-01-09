//
//  FirebaseBlogLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation
import FirebaseFirestore

class FirebaseBlogLibraryContentProvider: BlogLibraryContentProvider {
    
    private enum ContentType: String, Codable {
        case text
        case image
        case markdown
    }
    
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
    
    static let BLOG_POSTS = "BlogPosts"
    
    let blogPostsCollection = Firestore.firestore().collection(BLOG_POSTS)
    
    func loadBlogPosts(onUpdate: @escaping ([BlogPost]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            do {
                let snapshot = try await blogPostsCollection
                    .order(by: "publicationDate", descending: true)
                    .getDocuments()
                
                let blogPosts = try snapshot.documents
                    .compactMap { try $0.data(as: BlogPostDoc.self).toBlogPost() }
                
                onUpdate(blogPosts)
            } catch {
                print(error)
                onError(error)
            }
        }
    }
}
