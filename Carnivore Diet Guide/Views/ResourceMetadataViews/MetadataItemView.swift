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
    /// Shows the text as a gray placeholder, for a value that hasn't loaded yet.
    var isPlaceholder: Bool = false

    @State private var textState: String = ""
    @State private var iconState: String?

    var body: some View {
        HStack(spacing: 2) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
                .contentTransition(.numericText())
                .redacted(reason: isPlaceholder ? .placeholder : [])
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
