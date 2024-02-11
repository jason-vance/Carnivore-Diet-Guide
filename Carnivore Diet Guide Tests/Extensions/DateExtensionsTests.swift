//
//  DateExtensionsTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 2/10/24.
//

import XCTest

final class DateExtensionsTests: XCTestCase {

    func testTimeAgoString() throws {
        let testNow = Calendar.current.date(from: .init(year: 2024, month: 2, day: 10, hour: 10, minute: 30))!
        
        let thirtySecondsAgo = Calendar.current.date(byAdding: .second, value: -30, to: testNow)!
        XCTAssertEqual("moments ago", thirtySecondsAgo.timeAgoString(fromDate: testNow))
        
        let oneMinute59SecsAgo = Calendar.current.date(byAdding: .second, value: -119, to: testNow)!
        XCTAssertEqual("moments ago", oneMinute59SecsAgo.timeAgoString(fromDate: testNow))
        
        let twoMinutesAgo = Calendar.current.date(byAdding: .minute, value: -2, to: testNow)!
        XCTAssertEqual("2 minutes ago", twoMinutesAgo.timeAgoString(fromDate: testNow))
        
        let fiftyNineMinutesAgo = Calendar.current.date(byAdding: .minute, value: -59, to: testNow)!
        XCTAssertEqual("59 minutes ago", fiftyNineMinutesAgo.timeAgoString(fromDate: testNow))
        
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: testNow)!
        XCTAssertEqual("1 hour ago", oneHourAgo.timeAgoString(fromDate: testNow))
        
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: testNow)!
        XCTAssertEqual("2 hours ago", twoHoursAgo.timeAgoString(fromDate: testNow))
        
        let twentyThreeHoursAgo = Calendar.current.date(byAdding: .hour, value: -23, to: testNow)!
        XCTAssertEqual("23 hours ago", twentyThreeHoursAgo.timeAgoString(fromDate: testNow))
        
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: testNow)!
        XCTAssertEqual("1 day ago", oneDayAgo.timeAgoString(fromDate: testNow))
        
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: testNow)!
        XCTAssertEqual("2 days ago", twoDaysAgo.timeAgoString(fromDate: testNow))
        
        let sixDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: testNow)!
        XCTAssertEqual("6 days ago", sixDaysAgo.timeAgoString(fromDate: testNow))
        
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: testNow)!
        XCTAssertEqual("3 Feb 2024", oneWeekAgo.timeAgoString(fromDate: testNow))
        
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: testNow)!
        XCTAssertEqual("27 Jan 2024", twoWeeksAgo.timeAgoString(fromDate: testNow))
    }
}
