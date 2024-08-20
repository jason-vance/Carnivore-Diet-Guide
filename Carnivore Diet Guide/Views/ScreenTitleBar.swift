//
//  ScreenTitleBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct ScreenTitleBar: View {
    
    @State var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            TitleText()
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 0.25)
                .foregroundStyle(Color.text)
                .opacity(0.25)
        }
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(text)
            .font(.title.bold())
            .foregroundStyle(Color.text)
    }
}

#Preview {
    ScreenTitleBar("Community Feed")
}
