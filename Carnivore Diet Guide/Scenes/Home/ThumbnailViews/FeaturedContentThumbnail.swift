//
//  FeaturedContentThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI
import Kingfisher

struct FeaturedContentThumbnail: View {
    
    @State private var imageSize: CGFloat = 200
    
    @State var item: FeaturedContentItem = .empty
    
    var body: some View {
        VStack(spacing: 16) {
            ThumbnailImage()
                .overlay(alignment: .topLeading) {
                    Group {
                        switch item.type {
                        case .none:
                            Text("")
                        case .recipe(_):
                            Text("Featured Recipe")
                        case .post(_):
                            Text("Featured Post")
                        }
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.background)
                    .bold()
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.accent)
                }
                .overlay(alignment: .bottom) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.background)
                        .frame(maxWidth: .infinity)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.text)
                }
                .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
                .shadow(color: Color.accentText ,radius: 4)
        }
        .frame(width: imageSize, height: imageSize)
    }
    
    @ViewBuilder func ThumbnailImage() -> some View {
        if let imageName = item.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        if let imageUrl = item.imageUrl {
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
            FeaturedContentThumbnail(item: .samplePost)
            FeaturedContentThumbnail(item: .sampleRecipe)
        }
        .padding()
    }
}
