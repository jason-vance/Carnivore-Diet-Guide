//
//  ArrayExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
