//
//  CookingStep.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import Foundation

extension Recipe {
    //TODO: Maybe I should remove Identifiable, it's not actually a part of `CookingStep`
    struct CookingStep: Identifiable {
        var id = UUID().uuidString
        var title: String?
        var text: String?
    }
}
