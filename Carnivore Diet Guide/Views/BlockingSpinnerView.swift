//
//  BlockingSpinnerView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI

struct BlockingSpinnerView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.accentColor)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                ProgressView()
                    .tint(.white)
            }
        }
        .id("BlockingSpinnerView")
    }
}

#Preview {
    BlockingSpinnerView()
}
