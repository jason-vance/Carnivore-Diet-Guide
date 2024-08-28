//
//  ScreenTitleBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct ScreenTitleBar<LeftBarContent:View>: View {
    
    let text: String
    let leftBarContent: (() -> LeftBarContent)?
    
    init(_ text: String) where LeftBarContent == Text {
        self.text = text
        self.leftBarContent = nil
    }
    
    init(_ text: String, leftBarContent: @escaping () -> LeftBarContent) {
        self.text = text
        self.leftBarContent = leftBarContent
    }
    
    var body: some View {
        HStack {
            if let leftBarContent = leftBarContent {
                leftBarContent()
            }
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

#Preview("Title Only") {
    ScreenTitleBar("Screen Title Bar")
}

#Preview("LeftBarContent") {
    ScreenTitleBar("Screen Title Bar") {
        Button {
            
        } label: {
            Image(systemName: "chevron.backward")
                .font(.title.bold())
                .foregroundStyle(Color.accent)
        }
    }
}
