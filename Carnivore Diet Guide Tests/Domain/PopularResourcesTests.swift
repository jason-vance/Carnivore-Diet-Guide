//
//  PopularResourcesTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 2/12/24.
//

import XCTest

final class PopularResourcesTests: XCTestCase {

    func testIsEmptyUponInit() {
        let x = PopularResources()
        XCTAssertTrue(x.isEmpty)
    }
    
    func testSortsResourceIds() {
        var x = PopularResources()
        
        let id1 = "id1"
        let id2 = "id2"
        let id3 = "id3"

        for _ in 0..<10 {
            x.add(resourceId: id1)
        }
        for _ in 0..<20 {
            x.add(resourceId: id3)
        }
        for _ in 0..<15 {
            x.add(resourceId: id2)
        }
        
        let ids = x.getSortedResourceIds()
        XCTAssertEqual([id3, id2, id1], ids)
    }

}
