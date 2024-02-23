//
//  TitleBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct TitleBar: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State var text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .bold()
                .foregroundStyle(Color.text)
            Spacer()
        }
        .overlay(alignment: .leading) {
            DismissButton()
        }
        .padding()
        .background(Color.background)
    }
    
    @ViewBuilder func DismissButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
}

#Preview {
    TitleBar(text: "Title Bar")
}
