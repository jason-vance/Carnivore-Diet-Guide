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
        
        func throwIfNotValid(_ value: String) throws {
            switch self {
            case .notEmpty:
                if value.isEmpty { throw "Must not be empty" }
            case .minimumLength(let min):
                if value.count < min { throw "Must be at least \(min) characters" }
            case .maximumLength(let max):
                if value.count > max { throw "Must be less than \(max) characters" }
            case .regex(regex: let regex):
                if value.wholeMatch(of: regex) == nil { throw "Must match regex \(regex)" }
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
            validator: { value in try Self.throwIfNotValid(value, constraints: validationConstraints) },
            valueFormatter: { value in Self.format(value, constraints: formattingConstraints) }
        )
    }
    
    fileprivate static func appendTo(_ errorDescription: inout String, _ error: any Error) {
        if !errorDescription.isEmpty {
            errorDescription.append("\n")
        }
        errorDescription.append(error.localizedDescription)
    }
    
    static func throwIfNotValid(_ value: String, constraints: [ValidationConstraints]) throws {
        var errorDescription = ""
        
        for constraint in constraints {
            do {
                try constraint.throwIfNotValid(value)
            } catch {
                appendTo(&errorDescription, error)
            }
        }
        
        if !errorDescription.isEmpty {
            throw errorDescription
        }
    }
    
    static func format(_ value: String, constraints: [FormattingConstraint]) -> String {
        var value = value
        for constraint in constraints {
            value = constraint.format(value)
        }
        return value
    }
}
