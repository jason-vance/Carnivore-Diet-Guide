//
//  CacheTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 9/4/24.
//

import XCTest

final class CacheTests: XCTestCase {
    
    func testInsertionAndRetrieval() {
        // Given
        let cache = Cache<String, Int>()
        
        // When
        cache.insert(10, forKey: "testKey")
        
        // Then
        XCTAssertEqual(cache.value(forKey: "testKey"), 10)
    }
    
    func testValueExpiration() {
        // Given
        let dateProvider = { Calendar.current.date(byAdding: .second, value: -2, to: .now)! }
        let cache = Cache<String, Int>()
        cache.entryLifetime = 1
        
        // When
        cache.insert(20, forKey: "testKey", dateProvider: dateProvider)
        
        // Then
        XCTAssertNil(cache.value(forKey: "testKey"))
    }
    
    func testSubscript() {
        // Given
        let cache = Cache<String, Int>()
        
        // When
        cache["testKey"] = 30
        
        // Then
        XCTAssertEqual(cache["testKey"], 30)
    }
    
    func testValueRemoval() {
        // Given
        let cache = Cache<String, Int>()
        cache.insert(40, forKey: "testKey")
        
        // When
        cache.removeValue(forKey: "testKey")
        
        // Then
        XCTAssertNil(cache.value(forKey: "testKey"))
    }
    
    func testPersistence() throws {
        // Given
        let cache = Cache<String, Int>()
        cache.insert(50, forKey: "testKey")
        
        // When
        try cache.saveToDisk(withName: "testCache")
        let loadedCache: Cache<String, Int> = try Cache.readFromDisk(Cache.self, withName: "testCache")
        
        // Then
        XCTAssertEqual(loadedCache.value(forKey: "testKey"), 50)
    }

}
