//
//  ResourceOnDeviceWasViewedFlagger.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/24/24.
//

import Foundation
import Combine

enum WelcomeArticleInfo {
    static let showWelcomeArticleKey = "showWelcomeArticle"
    static let welcomeArticleId = "ADA8F00C-ED8E-4419-82F9-D802B76E10B5"
}

class ResourceOnDeviceWasViewedFlagger {
    
    public static let instance: ResourceOnDeviceWasViewedFlagger = .init()
    public static func getInstance() -> ResourceOnDeviceWasViewedFlagger { instance }
    
    func flagAsViewed(resource: Resource) {
        if resource.id == WelcomeArticleInfo.welcomeArticleId {
            UserDefaults.standard.set(false, forKey: WelcomeArticleInfo.showWelcomeArticleKey)
        }
    }
}
