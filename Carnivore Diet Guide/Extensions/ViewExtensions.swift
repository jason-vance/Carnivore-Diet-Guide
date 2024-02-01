//
//  ViewExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import SwiftUI

extension View {
    func onChange<V>(of: V, initial: Bool, perform: @escaping (V) -> ()) -> some View where V: Equatable {
        if #available(iOS 17.0, *) {
            return self.onChange(of: of, initial: initial) { oldValue, newValue in
                perform(newValue)
            }
        } else {
            if initial {
                perform(of)
            }
            return self.onChange(of: of, perform: { newValue in
                perform(newValue)
            })
        }
    }
}
