//
//  SearchKeywordSetExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation

extension Set<SearchKeyword> {
    func relevanceTo(_ string: String) -> UInt {
        self.relevanceTo(SearchKeyword.keywordsFrom(string: string))
    }
    
    func relevanceTo(_ keywords: Set<SearchKeyword>) -> UInt {
        filter { keywords.contains($0) }
            .reduce(0) { $0 + $1.score }
    }
}
