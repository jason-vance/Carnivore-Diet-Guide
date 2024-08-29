//
//  ResourceTagTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/28/24.
//

import XCTest

// Assuming Resource.Tag class is defined as in the previous example
class ResourceTagTests: XCTestCase {

    func testAcceptsValidTags() {
        // Valid single-word, alphanumeric tags
        XCTAssertNotNil(Resource.Tag("Swift"))
        XCTAssertNotNil(Resource.Tag("swift"))
        XCTAssertNotNil(Resource.Tag("coding"))
        
        // Valid tag with hyphen
        XCTAssertNotNil(Resource.Tag("code-snippet"))
        
        // Valid tag with minimum length
        XCTAssertNotNil(Resource.Tag("go"))
        
        // Valid tag with maximum length
        XCTAssertNotNil(Resource.Tag("this-is-a-very-long-tag-indeed"))
    }
    
    func testRejectsInvalidTags() {
        // Too short
        XCTAssertNil(Resource.Tag("a"))
        
        // Too long
        XCTAssertNil(Resource.Tag("this-is-a-super-long-tag-that-should-be-rejected"))
        
        // Contains invalid characters
        XCTAssertNil(Resource.Tag("swift@apple"))
        XCTAssertNil(Resource.Tag("hello world"))
        XCTAssertNil(Resource.Tag("invalid_tag!"))
        
        // Contains only spaces
        XCTAssertNil(Resource.Tag("    "))
        
        // Leading/trailing whitespace should be trimmed but still valid
        XCTAssertNotNil(Resource.Tag("   Swift  "))
        
        // Test with empty string
        XCTAssertNil(Resource.Tag(""))
        
        // Tag with multiple spaces should be rejected
        XCTAssertNil(Resource.Tag("swift programming"))
    }
    
    func testTagNormalization() {
        // Check if input is converted to lowercase
        let tag = Resource.Tag("SWIFT")
        XCTAssertEqual(tag?.text, "swift")
        
        // Check if leading/trailing spaces are trimmed
        let trimmedTag = Resource.Tag("   Swift  ")
        XCTAssertEqual(trimmedTag?.text, "swift")
    }
}
