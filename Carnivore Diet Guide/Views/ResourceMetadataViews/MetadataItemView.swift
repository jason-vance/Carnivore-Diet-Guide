//
//  MetadataItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import SwiftUI

struct MetadataItemView: View {
    
    let text: String
    let icon: String?
    
    @State private var textState: String = ""
    @State private var iconState: String?
    
    var body: some View {
        HStack(spacing: 2) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
                .contentTransition(.numericText())
        }
        .foregroundColor(Color.text)
        .font(.caption)
        .onChange(of: text, initial: true) { oldText, newText in
            textState = newText
        }
        .onChange(of: icon, initial: true) { oldIcon, newIcon in
            iconState = icon
        }
    }
}

#Preview {
    MetadataItemView(text: "Hello", icon: "circle")
}
