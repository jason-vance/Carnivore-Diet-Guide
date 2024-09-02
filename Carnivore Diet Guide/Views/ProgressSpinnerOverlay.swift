//
//  ProgressSpinnerOverlay.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI

struct ProgressSpinnerOverlay: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accentColor)
                .padding()
                .background(Color.background)
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        }
    }
}

#Preview {
    ProgressSpinnerOverlay()
}
