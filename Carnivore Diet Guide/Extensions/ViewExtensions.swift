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
    
    func taggedAsPremiumContent(_ isPremium: Bool = true) -> some View {
        self
            .overlay(alignment: .topTrailing) {
                if isPremium {
                    HStack {
                        Text("Carnivore+")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.background)
                    }
                    .padding(.horizontal, .paddingHorizontalButtonXSmall)
                    .padding(.vertical, .paddingVerticalButtonXSmall)
                    .background(Color.accent)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: .cornerRadiusMedium), style: .continuous))
                }
            }
    }
}
