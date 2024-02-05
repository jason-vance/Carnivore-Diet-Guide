//
//  PostDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import SwiftUI
import MarkdownUI

struct PostDetailView: View {
    
    let post: Post
    
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        VStack(spacing: 0) {
            PostHeader()
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(Color.text)
                ScrollView {
                    PostContent()
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color.background)
                .clipShape(.rect(topLeadingRadius: Corners.radius, topTrailingRadius: Corners.radius))
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func PostHeader() -> some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.title).bold()
                .foregroundStyle(Color.background)
            Text("By: \(String(localized: .init(post.author)))")
                .font(.subheadline).bold()
                .foregroundStyle(Color.darkAccentText)
            Text(post.publicationDate, style: .date)
                .font(.caption).bold()
                .foregroundStyle(Color.background)
            CloseButton()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.text, ignoresSafeAreaEdges: .top)
    }
    
    @ViewBuilder func PostContent() -> some View {
        Markdown(post.markdownContent)
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
                Image(systemName: "chevron.backward")
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
    PostDetailView(post: .sample)
}
