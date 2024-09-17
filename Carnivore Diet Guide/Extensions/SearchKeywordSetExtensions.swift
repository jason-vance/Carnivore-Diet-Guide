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
        print("OTHER KEYWORDS")
        keywords.forEach {
            print("\($0.text)")
        }
        
        print("SELF KEYWORDS")
        return filter {
            let contains = keywords.contains($0)
            print("\($0.text) \(contains)")
            return contains
        }
        .reduce(0) {
            print("\($1.text)")
            return $0 + $1.score
        }
    }
}
