//
//  Username.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class Username: ValueOf<String> {
    
    override class func validate(value: String) -> Bool {
        hasAtLeastThreeChars(value) &&
        onlyContainsLettersNumbersUnderscoresOrPeriods(value)
    }
    
    private class func hasAtLeastThreeChars(_ value: String) -> Bool {
        value.count >= 3
    }
    
    private class func onlyContainsLettersNumbersUnderscoresOrPeriods(_ value: String) -> Bool {
        value.filter({ !$0.isLetter && !$0.isWholeNumber && $0 != "_" && $0 != "." }).isEmpty
    }
}
