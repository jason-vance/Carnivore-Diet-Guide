//
//  BlogPostThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI

struct BlogPostThumbnail: View {
    
    @State var title: String
    @State var imageName: String
    @State var upvotes: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 0) {
                        Text("\(upvotes.formatted())")
                        Image(systemName: "hand.thumbsup.fill")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.background)
                    .padding(8)
                    .background(Color.accent)
                    .clipShape(.rect(bottomLeadingRadius: 16))
                }
                .overlay(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.background)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.text)
                }
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.accentText ,radius: 4)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                BlogPostThumbnail(
                    title: "Beef Bourguignon",
                    imageName: "BeefBourguignon",
                    upvotes: 65432
                )
                BlogPostThumbnail(
                    title: "Grilled Salmon with Lemon Butter",
                    imageName: "GrilledSalmonWithLemonButter",
                    upvotes: 7654
                )
            }
            HStack(spacing: 16) {
                BlogPostThumbnail(
                    title: "Spicy Mexican Beef Skillet",
                    imageName: "SpicyMexicanBeefSkillet",
                    upvotes: 876
                )
                BlogPostThumbnail(
                    title: "Sukiyaki-Style Beef",
                    imageName: "SukiyakiStyleBeef",
                    upvotes: 98
                )
            }
        }
        .padding()
    }
}
