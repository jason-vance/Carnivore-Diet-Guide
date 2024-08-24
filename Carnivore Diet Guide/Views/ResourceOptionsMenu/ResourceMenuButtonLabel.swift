//
//  ResourceMenuButtonLabel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import SwiftUI

struct ResourceMenuButtonLabel: View {
    
    let sfSymbol: String
    @State private var image: String = ""
    
    var body: some View {
        Image(systemName: sfSymbol)
            .resizable()
            .bold()
            .foregroundStyle(Color.accent)
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .contentTransition(.symbolEffect(.replace))
            .onChange(of: sfSymbol, initial: true) { oldSfSymbol, newSfSymbol in
                withAnimation(.snappy) {
                    self.image = newSfSymbol
                }
            }
    }
}

#Preview {
    ResourceMenuButtonLabel(sfSymbol: "circle")
}
