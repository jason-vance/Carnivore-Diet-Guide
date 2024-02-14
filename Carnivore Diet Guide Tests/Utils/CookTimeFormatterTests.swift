//
//  CookTimeFormatterTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 2/13/24.
//

import XCTest

final class CookTimeFormatterTests: XCTestCase {

    func testFormatting() throws {
        XCTAssertEqual("0mins", CookTimeFormatter.formatMinutes(0))
        XCTAssertEqual("1min", CookTimeFormatter.formatMinutes(1))
        XCTAssertEqual("5mins", CookTimeFormatter.formatMinutes(5))
        XCTAssertEqual("17mins", CookTimeFormatter.formatMinutes(17))
        XCTAssertEqual("59mins", CookTimeFormatter.formatMinutes(59))
        XCTAssertEqual("1hr", CookTimeFormatter.formatMinutes(60))
        XCTAssertEqual("1hr 15mins", CookTimeFormatter.formatMinutes(75))
        XCTAssertEqual("1hr 59mins", CookTimeFormatter.formatMinutes(119))
        XCTAssertEqual("2hrs", CookTimeFormatter.formatMinutes(120))
        XCTAssertEqual("2hrs 1min", CookTimeFormatter.formatMinutes(121))
    }
}
