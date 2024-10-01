//
//  Analytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation

protocol Analytics {
    func logScreenView(screenName: String, screenClass: Any)
}

class MockAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) { }
}
