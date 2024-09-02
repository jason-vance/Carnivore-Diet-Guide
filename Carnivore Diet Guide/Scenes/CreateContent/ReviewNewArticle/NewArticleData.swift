//
//  NewArticleData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import Foundation

struct NewArticleData: Hashable {
    let data: ContentData
    let metadata: ContentMetadata
    
    static let sample: NewArticleData = .init(data: .sample, metadata: .sample)
}
