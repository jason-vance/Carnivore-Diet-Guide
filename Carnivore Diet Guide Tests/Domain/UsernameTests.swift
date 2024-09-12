//
//  UsernameTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 9/12/24.
//

import XCTest

class UsernameTests: XCTestCase {
    
    func testValidUsername() {
        let validUsername = Username("valid.user123")
        XCTAssertNotNil(validUsername)
        XCTAssertEqual(validUsername?.value, "valid.user123")
    }

    func testUsernameTooShort() {
        let shortUsername = Username("ab")
        XCTAssertNil(shortUsername)
    }
    
    func testUsernameTooLong() {
        let longUsername = Username("averyveryveryveryveryveryveryveryverylongusername")
        XCTAssertNil(longUsername)
    }
    
    func testUsernameAllPeriods() {
        let username = Username("...")
        XCTAssertNil(username)
    }
    
    func testUsernameConsecutiveUnderscores() {
        let username = Username("user..name")
        XCTAssertNil(username)
    }
    
    func testUsernameAllNumbers() {
        let username = Username("12345")
        XCTAssertNil(username)
    }

    func testUsernameWithInvalidCharacters() {
        var invalidUsername = Username("user!name")
        XCTAssertNil(invalidUsername)
        
        invalidUsername = Username("user-name")
        XCTAssertNil(invalidUsername)
        
        invalidUsername = Username("user_name")
        XCTAssertNil(invalidUsername)
    }

    func testUsernameStartingWithNumber() {
        let invalidUsername = Username("1username")
        XCTAssertNil(invalidUsername)
    }

    func testUsernameWithSpaces() {
        let usernameWithSpaces = Username("   user.with.spaces   ")
        XCTAssertNotNil(usernameWithSpaces)
        XCTAssertEqual(usernameWithSpaces?.value, "user.with.spaces")
    }
    
    func testTheCarnivoreDietGuide() {
        let mixedCaseUsername = Username("theCarnivoreDietGuideTeam")
        XCTAssertNotNil(mixedCaseUsername)
        XCTAssertEqual(mixedCaseUsername?.value, "theCarnivoreDietGuideTeam")
    }

    func testUsernameEmpty() {
        let emptyUsername = Username("")
        XCTAssertNil(emptyUsername)
    }
}
