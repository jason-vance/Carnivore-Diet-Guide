//
//  CreateContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/29/24.
//

import SwiftUI

struct CreateContentView: View {
    
    @State private var contentType: Resource.ResourceType = .post
    
    var body: some View {
        switch contentType {
        case .post:
            CreatePostView(selectedContentType: $contentType)
        case .recipe:
            CreateRecipeView(selectedContentType: $contentType)
        }
    }
    
    @ViewBuilder static func TitleMenu(_ text: String, contentType: Binding<Resource.ResourceType>) -> some View {
        Menu {
            if contentType.wrappedValue != .post {
                Button {
                    contentType.wrappedValue = .post
                } label: {
                    Text("Post")
                }
            }
            if contentType.wrappedValue != .recipe {
                Button {
                    contentType.wrappedValue = .recipe
                } label: {
                    Text("Recipe")
                }
            }
        } label: {
            HStack {
                Text(text)
                ResourceMenuButtonLabel(sfSymbol: "chevron.down")
            }
        }
    }
}

#Preview {
    CreateContentView()
}
