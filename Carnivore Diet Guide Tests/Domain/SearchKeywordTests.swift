//
//  SearchKeywordTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/30/24.
//

import XCTest

final class SearchKeywordTests: XCTestCase {
    
    func testAcceptsValidSummary() {
        XCTAssertNotNil(SearchKeyword("Swift"))
        XCTAssertNotNil(SearchKeyword("swift"))
        XCTAssertNotNil(SearchKeyword("coding"))
    }
    
    func testRejectsInvalidTags() {
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
    }
    
    func testKeywordNormalization() {
        // Check if input is converted to lowercase
        let keyword = SearchKeyword("SWIFT")
        XCTAssertEqual(keyword?.text, "swift")
        
        // Check if leading/trailing spaces are trimmed
        let trimmedKeyword = SearchKeyword("   Swift  ")
        XCTAssertEqual(trimmedKeyword?.text, "swift")
    }

}
