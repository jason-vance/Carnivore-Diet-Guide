//
//  Username.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation

struct Username {
    var value: String

    init?(_ input: String) {
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard Username.isValidLength(formattedInput),
              Username.containsOnlyAllowedCharacters(formattedInput),
              Username.doesNotStartWithNumber(formattedInput),
              Username.containsAtLeastOneAlphanumeric(formattedInput),
              Username.doesNotContainConsecutivePeriods(formattedInput),
              Username.containsAtLeastOneLetter(formattedInput) else {
            return nil
        }

        self.value = formattedInput
    }

    private static func isValidLength(_ input: String) -> Bool {
        return input.count >= 3 && input.count <= 32
    }

    // Validation: Ensure the username contains only allowed characters (letters, numbers, periods)
    private static func containsOnlyAllowedCharacters(_ input: String) -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(.init(charactersIn: "."))
        return input.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
    }

    private static func doesNotStartWithNumber(_ input: String) -> Bool {
        guard let firstCharacter = input.first else { return false }
        return !firstCharacter.isNumber
    }
    
    private static func containsAtLeastOneAlphanumeric(_ input: String) -> Bool {
        let alphanumericCharacterSet = CharacterSet.alphanumerics
        return input.rangeOfCharacter(from: alphanumericCharacterSet) != nil
    }
    
    private static func doesNotContainConsecutivePeriods(_ input: String) -> Bool {
        return !input.contains("..")
    }
    
    private static func containsAtLeastOneLetter(_ input: String) -> Bool {
        let letterCharacterSet = CharacterSet.letters
        return input.rangeOfCharacter(from: letterCharacterSet) != nil
    }
}

extension Username: Equatable {
    static func ==(_ lhs: Username, _ rhs: Username) -> Bool {
        lhs.value == rhs.value
    }
}
