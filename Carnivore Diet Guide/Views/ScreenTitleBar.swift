//
//  ScreenTitleBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct ScreenTitleBar<PrimaryContent:View,LeadingContent:View,TrailingContent:View>: View {
    
    let primaryContent: () -> PrimaryContent
    let leadingContent: (() -> LeadingContent)?
    let trailingContent: (() -> TrailingContent)?

    init(
        _ text: String
    ) where PrimaryContent == Text, LeadingContent == Text, TrailingContent == Text {
        self.primaryContent = { Text(text) }
        self.leadingContent = nil
        self.trailingContent = nil
    }
    
    init(
        _ text: String,
        leadingContent: @escaping () -> LeadingContent
    ) where PrimaryContent == Text, TrailingContent == Text {
        self.primaryContent = { Text(text) }
        self.leadingContent = leadingContent
        self.trailingContent = nil
    }
    
    init(
        primaryContent: @escaping () -> PrimaryContent,
        leadingContent: @escaping () -> LeadingContent,
        trailingContent: @escaping () -> TrailingContent
    ) {
        self.primaryContent = primaryContent
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let leadingContent = leadingContent {
                leadingContent()
            }
            TitleText()
            Spacer(minLength: 0)
            if let trailingContent = trailingContent {
                trailingContent()
            }
        }
        .padding(.horizontal)
        .frame(height: .defaultBarHeight)
        .overlay(alignment: .bottom) { BarDivider() }
    }
    
    @ViewBuilder func TitleText() -> some View {
        primaryContent()
            .font(.title.bold())
            .foregroundStyle(Color.text)
    }
}

#Preview("Title Only") {
    ScreenTitleBar("Screen Title Bar")
}

#Preview("LeftBarContent") {
    ScreenTitleBar("Screen Title Bar") {
        Button {
            
        } label: {
            Image(systemName: "chevron.backward")
                .font(.title.bold())
                .foregroundStyle(Color.accent)
        }
    }
}

#Preview("ComplexContent") {
    ScreenTitleBar {
        Menu {
            Text("Posts")
            Text("Article")
            Text("Recipe")
        } label: {
            HStack {
                Text("Post")
                ResourceMenuButtonLabel(sfSymbol: "chevron.down")
            }
        }
    } leadingContent: {
        Button {
            
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    } trailingContent: {
        HStack {
            Button {
                
            } label: {
                ResourceMenuButtonLabel(sfSymbol: "circle")
            }
            Button {
                
            } label: {
                ResourceMenuButtonLabel(sfSymbol: "heart")
            }
        }
    }
}
