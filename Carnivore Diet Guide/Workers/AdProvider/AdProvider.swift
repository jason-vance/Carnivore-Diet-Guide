//
//  AdProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation

class AdProvider {
    
    @Published public private(set) var showAds: Bool = true
    var showAdsPublisher: Published<Bool>.Publisher { $showAds }
    
    public static let instance: AdProvider = {
        .init()
    }()
    
    private init() {}
    
    func disableAds(_ disabled: Bool = true) {
        showAds = !disabled
    }
}
