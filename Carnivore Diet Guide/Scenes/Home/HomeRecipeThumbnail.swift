//
//  HomeRecipeThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI
import Kingfisher

struct HomeRecipeThumbnail: View {
    
    @State private var imageSize: CGFloat = 200
    
    @State var title: String
    @State var imageUrl: String?
    @State var imageName: String?

    var body: some View {
        VStack(spacing: 0) {
            ThumbnailImage()
                .overlay(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.text)
                        .frame(maxWidth: .infinity)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.background)
                }
        }
        .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
        .shadow(color: Color.darkAccentText ,radius: 4)
        .frame(width: imageSize, height: imageSize)
    }
    
    @ViewBuilder func ThumbnailImage() -> some View {
        if let imageName = imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        if let imageUrl = imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundStyle(Color.background)
                }
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            HomeRecipeThumbnail(
                title: "Beef Bourguignon",
                imageName: "BeefBourguignon"
            )
            HomeRecipeThumbnail(
                title: "Grilled Salmon with Lemon Butter",
                imageName: "GrilledSalmonWithLemonButter"
            )
            HomeRecipeThumbnail(
                title: "Spicy Mexican Beef Skillet",
                imageName: "SpicyMexicanBeefSkillet"
            )
            HomeRecipeThumbnail(
                title: "Sukiyaki-Style Beef",
                imageName: "SukiyakiStyleBeef"
            )
        }
        .padding()
    }
}
