//
//  StringExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

extension String: Error {}
extension String: LocalizedError {
    public var errorDescription: String? { self }
}
