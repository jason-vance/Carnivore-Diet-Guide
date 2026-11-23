//
//  ValueOf.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/12/23.
//
//  Copied from the ValueOf package (bitbucket.org/jasonvance77/valueof, fa695b4) so builds don't depend
//  on reaching Bitbucket.
//

import Foundation

open class ValueOf<T>: Equatable where T: Equatable {
    
    public enum ValueOfError: Error {
        case invalidValue(value: T)
    }
    
    public let value: T
    
    public init(
        _ value: T,
        validator: (T) throws -> (),
        valueFormatter: ((T) -> T)? = nil
    ) throws {
        let formattedValue = valueFormatter?(value) ?? value
        try validator(formattedValue)
        self.value = formattedValue
    }
    
    public init(
        _ value: T,
        valueFormatter: (T) -> T
    ) {
        self.value = valueFormatter(value)
    }
    
    public static func == (lhs: ValueOf, rhs: ValueOf) -> Bool {
        return lhs.equals(rhs)
    }
    
    open func equals(_ other: ValueOf) -> Bool {
        guard let _ = other as? Self else {
            return false
        }
        return self.value == other.value
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
extension ValueOf: Identifiable where T: Identifiable { }

extension ValueOf: Hashable where T: Hashable {
    
    public var hashValue: Int { value.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension ValueOf: Comparable where T: Comparable {
    
    public static func < (lhs: ValueOf<T>, rhs: ValueOf<T>) -> Bool {
        return lhs.value < rhs.value
    }
}

extension ValueOf: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    
    public var debugDescription: String { value.debugDescription }
}
