//
//  ReviewContentSectionHeader.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI

struct ReviewContentSectionHeader: View {
    
    @State var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.text)
            Text(text)
                .font(.callout)
                .padding(.horizontal, 8)
                .background(Color.background)
                .foregroundStyle(Color.text)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    ReviewContentSectionHeader("ReviewContentSectionHeader")
}
