//
//  ResourceImageView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI
import Kingfisher

struct ResourceImageView: View {
    
    public let url: URL?
    
    var body: some View {
        GeometryReader { proxy in
            let imageWidth = proxy.size.width
            
            KFImage(url)
                .resizable()
                .cacheOriginalImage()
                .diskCacheExpiration(.days(7))
                .placeholder { PlaceholderView(imageWidth: imageWidth) }
                .scaledToFill()
                .frame(width: imageWidth, height: imageWidth)
                .clipShape(Square())
        }
        .aspectRatio(1, contentMode: .fill)
    }
    
    @ViewBuilder func PlaceholderView(imageWidth: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.text.opacity(0.8))
            Image(systemName: "photo")
                .font(.system(size: imageWidth / 2))
                .foregroundStyle(Color.background)
        }
    }
}

#Preview {
    ResourceImageView(url: FeedItem.samplePost.imageUrls[0])
}
