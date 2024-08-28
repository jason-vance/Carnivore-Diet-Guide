//
//  AppVersion.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

enum AppVersion {
    
    static var appVersion: String? {
        let bundleDict = Bundle.main.infoDictionary!
        return bundleDict["CFBundleShortVersionString"] as? String
    }
    
    static var buildNumber: String? {
        let bundleDict = Bundle.main.infoDictionary!
        return bundleDict["CFBundleVersion"] as? String
    }
}

