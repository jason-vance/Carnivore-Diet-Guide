//
//  ConstrainedString.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/11/24.
//

import Foundation
import ValueOf

class ConstrainedString: ValueOf<String> {
    
    enum ValidationConstraints {
        case notEmpty
        case minimumLength(_ min: Int)
        case maximumLength(_ max: Int)
        case regex(regex: Regex<Substring>)
        
        func validate(_ value: String) -> Bool {
            switch self {
            case .notEmpty:
                return !value.isEmpty
            case .minimumLength(let min):
                return value.count >= min
            case .maximumLength(let max):
                return value.count <= max
            case .regex(regex: let regex):
                return value.wholeMatch(of: regex) != nil
            }
        }
    }
    
    enum FormattingConstraint {
        case trimmed
        
        func format(_ value: String) -> String {
            switch self {
            case .trimmed:
                return value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    init(_ value: String, validationConstraints: [ValidationConstraints] = [], formattingConstraints: [FormattingConstraint] = []) throws {
        try super.init(
            value,
            validator: { value in Self.validate(value, constraints: validationConstraints) },
            valueFormatter: { value in Self.format(value, constraints: formattingConstraints) }
        )
    }
    
    static func validate(_ value: String, constraints: [ValidationConstraints]) -> Bool {
        var isValid = true
        for constraint in constraints {
            isValid = isValid && constraint.validate(value)
        }
        return isValid
    }
    
    static func format(_ value: String, constraints: [FormattingConstraint]) -> String {
        var value = value
        for constraint in constraints {
            value = constraint.format(value)
        }
        return value
    }
}
