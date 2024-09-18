//
//  TextError.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/18/24.
//

import Foundation

struct TextError: Error, LocalizedError {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    public var errorDescription: String? { text }
}
