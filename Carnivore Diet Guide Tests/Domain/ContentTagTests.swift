//
//  ContentTagTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/28/24.
//

import XCTest

// Assuming ContentTag class is defined as in the previous example
class ContentTagTests: XCTestCase {

    func testAcceptsValidTags() {
        // Valid single-word, alphanumeric tags
        XCTAssertNotNil(ContentTag("Swift"))
        XCTAssertNotNil(ContentTag("swift"))
        XCTAssertNotNil(ContentTag("coding"))
        
        // Valid tag with hyphen
        XCTAssertNotNil(ContentTag("code-snippet"))
        
        // Valid tag with minimum length
        XCTAssertNotNil(ContentTag("go"))
        
        // Valid tag with maximum length
        XCTAssertNotNil(ContentTag("this-is-a-very-long-tag-indeed"))
    }
    
    func testRejectsInvalidTags() {
        // Too short
        XCTAssertNil(ContentTag("a"))
        
        // Too long
        XCTAssertNil(ContentTag("this-is-a-super-long-tag-that-should-be-rejected"))
        
        // Contains invalid characters
        XCTAssertNil(ContentTag("swift@apple"))
        XCTAssertNil(ContentTag("hello world"))
        XCTAssertNil(ContentTag("invalid_tag!"))
        
        // Contains only spaces
        XCTAssertNil(ContentTag("    "))
        
        // Leading/trailing whitespace should be trimmed but still valid
        XCTAssertNotNil(ContentTag("   Swift  "))
        
        // Test with empty string
        XCTAssertNil(ContentTag(""))
        
        // Tag with multiple spaces should be rejected
        XCTAssertNil(ContentTag("swift programming"))
    }
    
    func testTagNormalization() {
        // Check if input is converted to lowercase
        let tag = ContentTag("SWIFT")
        XCTAssertEqual(tag?.text, "swift")
        
        // Check if leading/trailing spaces are trimmed
        let trimmedTag = ContentTag("   Swift  ")
        XCTAssertEqual(trimmedTag?.text, "swift")
    }
}
