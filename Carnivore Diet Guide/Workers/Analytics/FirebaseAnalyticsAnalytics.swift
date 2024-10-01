//
//  FirebaseAnalyticsAnalytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) {
        FirebaseAnalytics.Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screenName,
                AnalyticsParameterScreenClass: String(describing: screenClass)
            ]
        )
    }
}
