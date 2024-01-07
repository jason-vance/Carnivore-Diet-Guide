//
//  FeaturedContentThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI

struct FeaturedContentThumbnail: View {
    
    enum FeaturedContentType {
        case recipe
        case blog
    }
    
    @State var title: String
    @State var imageName: String
    @State var type: FeaturedContentType
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(alignment: .topLeading) {
                        Text(type == .recipe ? "Featured Recipe" : "Featured Blog Post")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.background)
                            .bold()
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.accent)
                    }
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
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        HStack(spacing: 16) {
            FeaturedContentThumbnail(
                title: "Getting Started with the Carnivore Diet",
                imageName: "StartingCarnivoreDiet",
                type: .blog
            )
            FeaturedContentThumbnail(
                title: "Seared Ribeye Steak",
                imageName: "SearedRibeyeSteak",
                type: .recipe
            )
        }
        .padding()
    }
}
