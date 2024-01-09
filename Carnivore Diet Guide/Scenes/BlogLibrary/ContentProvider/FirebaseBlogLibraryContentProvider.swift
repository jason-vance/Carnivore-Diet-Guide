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
        struct ContentItem: Codable {
            var type: ContentType?
            var text: String?
            var markdown: String?
            var url: String?
            var caption: String?
            
            func toBlogPostContentItem() -> (any BlogPostContentItem)? {
                switch type {
                case .image:
                    if let url = url {
                        return BlogPost.ImageItem(url: url, caption: caption)
                    }
                case .markdown:
                    if let markdown = markdown {
                        return BlogPost.MarkdownItem(markdown: markdown.replacingOccurrences(of: "\\n", with: "\n"))
                    }
                default:
                    if let text = text {
                        return BlogPost.TextItem(text: text)
                    }
                }
                
                return nil
            }
        }
        
        @DocumentID var id: String?
        var publicationDate: Date?
        var title: String?
        var author: String?
        var imageUrl: String?
        var content: [ContentItem]
        
        func toBlogPost() -> BlogPost? {
            guard let title = title else { return nil }
            guard let imageUrl = imageUrl else { return nil }
            guard let author = author else { return nil }
            guard let publicationDate = publicationDate else { return nil }
            
            let content = content.compactMap { $0.toBlogPostContentItem() }

            return .init(
                title: title,
                imageUrl: imageUrl,
                author: author,
                content: content,
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
                
                let blogPosts = snapshot.documents
                    .compactMap { (try? $0.data(as: BlogPostDoc.self))?.toBlogPost() }
                
                onUpdate(blogPosts)
            } catch {
                onError(error)
            }
        }
    }
}
