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
        case .article:
            CreateArticleView(selectedContentType: $contentType)
        case .post:
            CreatePostView(selectedContentType: $contentType)
        case .recipe:
            CreateRecipeView(selectedContentType: $contentType)
        }
    }
    
    @ViewBuilder static func TitleMenu(_ text: String, contentType: Binding<Resource.ResourceType>) -> some View {
        Menu {
            Button {
                contentType.wrappedValue = .article
            } label: {
                LabeledContent("Article") {
                    if contentType.wrappedValue == .article {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                contentType.wrappedValue = .post
            } label: {
                LabeledContent("Post") {
                    if contentType.wrappedValue == .post {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                contentType.wrappedValue = .recipe
            } label: {
                LabeledContent("Recipe") {
                    if contentType.wrappedValue == .recipe {
                        Image(systemName: "checkmark")
                    }
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
