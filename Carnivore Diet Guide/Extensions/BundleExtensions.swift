//
//  BundleExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

extension Bundle {
    
    var displayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
