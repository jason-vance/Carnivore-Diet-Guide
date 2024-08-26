//
//  FirestorePostDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirestorePostDoc: Codable {
    
    @DocumentID var id: String?
    var publicationDate: Date?
    var author: String?
    var imageUrls: [String]?
    var title: String?
    var markdownContent: String?
    
    static func from(_ post: Post) -> FirestorePostDoc {
        return .init(
            id: post.id,
            publicationDate: post.publicationDate,
            author: post.author,
            imageUrls: post.imageUrls.map { $0.absoluteString },
            title: post.title,
            markdownContent: post.markdownContent
        )
    }
    
    func toPost() -> Post? {
        guard let id = id else { return nil }
        guard let title = title else { return nil }
        guard let author = author else { return nil }
        guard let markdownContent = markdownContent else { return nil }
        guard let publicationDate = publicationDate else { return nil }
        
        let imageUrls = imageUrls?.compactMap { URL(string: $0) } ?? []

        return .init(
            id: id,
            title: title,
            imageUrls: imageUrls,
            author: author,
            //TODO: Do I still need this replacement?
            markdownContent: markdownContent.replacingOccurrences(of: "\\n", with: "\n"),
            publicationDate: publicationDate
        )
    }
}
