//
//  HomeBlogPostThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI

struct HomeBlogPostThumbnail: View {
    
    @State var title: String
    @State var imageName: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.background)
                        .frame(maxWidth: .infinity)
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
                HomeBlogPostThumbnail(
                    title: "Beef Bourguignon",
                    imageName: "BeefBourguignon"
                )
                HomeBlogPostThumbnail(
                    title: "Grilled Salmon with Lemon Butter",
                    imageName: "GrilledSalmonWithLemonButter"
                )
            }
            HStack(spacing: 16) {
                HomeBlogPostThumbnail(
                    title: "Spicy Mexican Beef Skillet",
                    imageName: "SpicyMexicanBeefSkillet"
                )
                HomeBlogPostThumbnail(
                    title: "Sukiyaki-Style Beef",
                    imageName: "SukiyakiStyleBeef"
                )
            }
        }
        .padding()
    }
}
