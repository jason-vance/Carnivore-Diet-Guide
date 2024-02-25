//
//  ScrollViewShroud.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import SwiftUI

struct ScrollViewShroud: View {
    
    var body: some View {
        LinearGradient(
            colors: [Color.background, Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: .scrollShroudHeight)
    }
}

#Preview {
    ScrollViewShroud()
}
