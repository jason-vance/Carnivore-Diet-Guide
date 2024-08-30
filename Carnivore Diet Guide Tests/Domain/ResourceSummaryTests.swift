//
//  ResourceSummaryTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 8/30/24.
//

import XCTest

final class ResourceSummaryTests: XCTestCase {
    
    func testAcceptsValidKeywords() {
        // Valid single-word, alphabet containing keywords
        XCTAssertNotNil(Resource.Summary("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."))
    }
    
    func testRejectsInvalidKeywords() {
        // Empty
        XCTAssertNil(Resource.Summary(""))
        
        // Too short
        XCTAssertNil(Resource.Summary("Carnivore"))
        
        // Too long
        XCTAssertNil(Resource.Summary("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."))
        // Contains only spaces
        XCTAssertNil(Resource.Summary("                   "))
    }

}
