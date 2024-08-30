//
//  ResourceCategoryTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/30/24.
//

import XCTest

final class ResourceCategoryTests: XCTestCase {
    
    func testAcceptsValidTags() {
        // Valid single-word, alphanumeric tags
        XCTAssertNotNil(Resource.Category("Swift"))
        XCTAssertNotNil(Resource.Category("swift"))
        XCTAssertNotNil(Resource.Category("coding"))
        
        // Valid tag with hyphen
        XCTAssertNotNil(Resource.Category("code-snippet"))
        
        // Valid tag with plus
        XCTAssertNotNil(Resource.Category("Carnivore+"))
        
        // Valid tag with spaces
        XCTAssertNotNil(Resource.Category("how to"))
        
        // Valid tag with minimum length
        XCTAssertNotNil(Resource.Category("go"))
        
        // Valid tag with ampersand
        XCTAssertNotNil(Resource.Category("Challenges & Considerations"))
        
        // Valid tag with maximum length
        XCTAssertNotNil(Resource.Category("this-is-a-long-category-indeed"))
    }
    
    func testRejectsInvalidTags() {
        // Too short
        XCTAssertNil(Resource.Category("a"))
        
        // Too long
        XCTAssertNil(Resource.Category("this-is-a-super-long-category-that-should-be-rejected"))
        
        // Contains invalid characters
        XCTAssertNil(Resource.Category("swift@apple"))
        XCTAssertNil(Resource.Category("invalid_tag!"))
        
        // Contains only spaces
        XCTAssertNil(Resource.Category("    "))
        
        // Test with empty string
        XCTAssertNil(Resource.Category(""))
    }
    
    func testTagNormalization() {
        // Check if input is converted to lowercase
        let category = Resource.Category("SWIFT")
        XCTAssertEqual(category?.name, "Swift")
        
        // Check if leading/trailing spaces are trimmed
        let trimmedCategory = Resource.Category("   Swift  ")
        XCTAssertEqual(trimmedCategory?.name, "Swift")
        
        // Check if input is capitalized
        let capitalizedCategory = Resource.Category("how to")
        XCTAssertEqual(capitalizedCategory?.name, "How To")
    }

}
