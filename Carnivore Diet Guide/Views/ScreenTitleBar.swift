//
//  ScreenTitleBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct ScreenTitleBar: View {
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            TitleText()
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: .defaultBarHeight)
        .overlay(alignment: .bottom) { BarDivider() }
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(text)
            .font(.title.bold())
            .foregroundStyle(Color.text)
    }
}

#Preview {
    ScreenTitleBar("Screen Title Bar")
}
