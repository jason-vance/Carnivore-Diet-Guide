//
//  ResourceOnDeviceWasViewedFlagger.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/24/24.
//

import Foundation
import Combine

class ResourceOnDeviceWasViewedFlagger {
    
    public static let instance: ResourceOnDeviceWasViewedFlagger = .init()
    public static func getInstance() -> ResourceOnDeviceWasViewedFlagger { instance }
    
    func flagAsViewed(resource: Resource) {
        if resource.id == FeaturedArticlesView.welcomeArticleId {
            UserDefaults.standard.set(false, forKey: FeaturedArticlesView.showWelcomeArticleKey)
        }
    }
}
