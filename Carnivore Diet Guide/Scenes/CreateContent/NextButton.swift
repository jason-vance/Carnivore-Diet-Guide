//
//  NextButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/31/24.
//

import SwiftUI

struct NextButton: View {
    
    public let action: () -> ()
    private var isDisabled: Bool
    
    init(action: @escaping () -> Void) {
        self.action = action
        self.isDisabled = false
    }
    
    func disabled(_ disabled: Bool = true) -> NextButton {
        var view = self
        view.isDisabled = disabled
        return view
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Next")
                .foregroundStyle(Color.background)
                .font(.caption.bold())
                .padding(.horizontal, .paddingHorizontalButtonSmall)
                .padding(.vertical, .paddingVerticalButtonSmall)
                .background() {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(isDisabled ? Color.gray : Color.accent)
                }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

#Preview {
    NextButton { }
}
