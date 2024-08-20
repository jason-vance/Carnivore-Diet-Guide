//
//  RecipesView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct RecipesView: View {
    
    @StateObject private var model = RecipesViewModel()
    
    var body: some View {
        VStack {
            ScreenTitleBar(String(localized: "Recipes"))
            Spacer()
        }
        .background(Color.background)
    }
}

#Preview {
    RecipesView()
}
