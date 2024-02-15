//
//  HomeViewV2.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI

struct HomeViewV2: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.background)
                .ignoresSafeArea()
            Text("Hello, World!")
                .foregroundStyle(Color.text)
        }
        .overlay {
            CreateMenu()
        }
    }
}

#Preview {
    HomeViewV2()
}
