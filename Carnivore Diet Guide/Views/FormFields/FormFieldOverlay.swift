//
//  FormFieldOverlay.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct FormFieldOverlay: View {
    
    var action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .stroke(
                    Color.accentColor,
                    style: .init(lineWidth: .borderWidthThin))
        }
    }
}

#Preview {
    FormFieldOverlay {}
}
