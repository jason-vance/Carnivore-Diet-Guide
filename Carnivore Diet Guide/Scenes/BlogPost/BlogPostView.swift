//
//  BlogPostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import SwiftUI
import MarkdownUI

struct BlogPostView: View {
    
    let blogPost: BlogPost
    
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        VStack(spacing: 0) {
            BlogPostHeader()
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(Color.text)
                ScrollView {
                    BlogPostContent()
                        .padding()
                }
                .background(Color.background)
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func BlogPostHeader() -> some View {
        VStack(alignment: .leading) {
            Text(blogPost.title)
                .font(.title).bold()
                .foregroundStyle(Color.background)
            Text("By: \(String(localized: .init(blogPost.author)))")
                .font(.subheadline).bold()
                .foregroundStyle(Color.darkAccentText)
            Text(blogPost.publicationDate, style: .date)
                .font(.caption).bold()
                .foregroundStyle(Color.background)
            CloseButton()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.text, ignoresSafeAreaEdges: .top)
    }
    
    @ViewBuilder func BlogPostContent() -> some View {
        Markdown(blogPost.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.accent)
                    .frame(width: 44, height: 44)
                Image(systemName: "chevron.left")
                    .resizable()
                    .bold()
                    .foregroundStyle(Color.background)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
        }
    }
}

#Preview {
    BlogPostView(blogPost: .sample)
}
