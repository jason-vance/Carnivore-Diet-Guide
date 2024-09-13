//
//  SearchKeywordTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/30/24.
//

import XCTest

final class SearchKeywordTests: XCTestCase {
    
    func testAcceptsValidKeywords() {
        XCTAssertNotNil(SearchKeyword("Swift"))
        XCTAssertNotNil(SearchKeyword("swift"))
        XCTAssertNotNil(SearchKeyword("coding"))
        XCTAssertNotNil(SearchKeyword("coding", score: 1))
    }
    
    func testRejectsInvalidKeywords() {
        // Empty
        XCTAssertNil(SearchKeyword(""))
        
        // Too long
        XCTAssertNil(SearchKeyword("thisIsASuperLongTagThatShouldBeRejected"))
        
        // Contains invalid characters
        XCTAssertNil(SearchKeyword("@apple"))
        XCTAssertNil(SearchKeyword("hello world"))
        XCTAssertNil(SearchKeyword("invalid-keyword!"))
        XCTAssertNil(SearchKeyword("butter1"))
        
        // Contains only spaces
        XCTAssertNil(SearchKeyword("    "))
        
        // Valid text, but invalid score
        XCTAssertNil(SearchKeyword("hello", score: 0))
    }
    
    func testKeywordNormalization() {
        // Check if input is converted to lowercase
        let keyword = SearchKeyword("SWIFT")
        XCTAssertEqual(keyword?.text, "swift")
        
        // Check if leading/trailing spaces are trimmed
        let trimmedKeyword = SearchKeyword("   Swift  ")
        XCTAssertEqual(trimmedKeyword?.text, "swift")
    }
    
    func testFromString() {
        let swiftKeyword = SearchKeyword("swift")!
        let codeKeyword = SearchKeyword("code")!
        
        // Checks correct score
        var keywords = SearchKeyword.keywordsFrom(string: "swift swift swift")
        XCTAssertEqual(3, keywords.first!.score)
        
        keywords = SearchKeyword.keywordsFrom(string: "swift swift swift code")
        XCTAssert(keywords.contains(swiftKeyword))
        XCTAssert(keywords.contains(codeKeyword))
    }
    
    func testFromStringLongString() {
        // Checks correct score
        let keywords = SearchKeyword.keywordsFrom(string: """
                                                  Carnivore Carnivore
                                                  Carnivore Carnivore Carnivore Carnivore
                                                  Carnivore Carnivore Carnivore Carnivore Carnivore
        """
        )
        XCTAssertEqual(11, keywords.first!.score)
    }

}
