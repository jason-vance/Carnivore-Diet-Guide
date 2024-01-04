//
//  RecipeThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/3/24.
//

import SwiftUI

struct RecipeThumbnail: View {
    
    @State var title: String
    @State var imageName: String
    @State var rating: Float
    
    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 0) {
                        Text(rating.formatted())
                        Image(systemName: "star.fill")
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
                        .foregroundStyle(Color.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.background)
                }
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.cardBackground ,radius: 4)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                RecipeThumbnail(
                    title: "Beef Bourguignon",
                    imageName: "BeefBourguignon",
                    rating: 3.4
                )
                RecipeThumbnail(
                    title: "Grilled Salmon with Lemon Butter",
                    imageName: "GrilledSalmonWithLemonButter",
                    rating: 4.5
                )
            }
            HStack(spacing: 16) {
                RecipeThumbnail(
                    title: "Spicy Mexican Beef Skillet",
                    imageName: "SpicyMexicanBeefSkillet",
                    rating: 4.6
                )
                RecipeThumbnail(
                    title: "Sukiyaki-Style Beef",
                    imageName: "SukiyakiStyleBeef",
                    rating: 4.7
                )
            }
        }
        .padding()
    }
}
