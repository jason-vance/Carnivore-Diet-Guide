//
//  ConstrainedStringTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 3/11/24.
//

import XCTest

final class ConstrainedStringTests: XCTestCase {
    
    func testNotEmptyConstraint() throws {
        let empty = try? ConstrainedString("", validationConstraints: [.notEmpty])
        XCTAssertNil(empty)
        
        let notEmpty = try? ConstrainedString("hello", validationConstraints: [.notEmpty])
        XCTAssertNotNil(notEmpty)
    }
    
    func testLengthLimitConstraint() throws {
        let tooLong = try? ConstrainedString("hello hello hello", validationConstraints: [.maximumLength(10)])
        XCTAssertNil(tooLong)
        
        let shortEnough = try? ConstrainedString("hello", validationConstraints: [.maximumLength(10)])
        XCTAssertNotNil(shortEnough)
    }
    
    func testLengthMinimumConstraint() throws {
        let tooShort = try? ConstrainedString("hi", validationConstraints: [.minimumLength(3)])
        XCTAssertNil(tooShort)
        
        let longEnough = try? ConstrainedString("hello", validationConstraints: [.minimumLength(3)])
        XCTAssertNotNil(longEnough)
    }
    
    func testRegexConstraint() throws {
        let noMatch = try? ConstrainedString("hello", validationConstraints: [.regex(regex: /goodbye/)])
        XCTAssertNil(noMatch)
        
        let match = try? ConstrainedString("hello", validationConstraints: [.regex(regex: /hello/)])
        XCTAssertNotNil(match)
    }
    
    func testTrimmedConstraint() throws {
        let trimmed = try? ConstrainedString("    hello\n\n", formattingConstraints: [.trimmed])
        XCTAssertEqual("hello", trimmed?.value)
    }

}
