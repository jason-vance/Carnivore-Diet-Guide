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
    private var __aspectRatio: CGFloat
    
    @State private var aspectRatio: CGFloat
    
    init(url: URL?) {
        self.url = url
        self.__aspectRatio = 1
        self.aspectRatio = 1
    }
    
    public func aspectRatio(_ aspectRatio: CGFloat) -> ResourceImageView {
        var view = self
        view.__aspectRatio = aspectRatio
        return view
    }
    
    var body: some View {
        GeometryReader { proxy in
            let imageWidth = proxy.size.width
            
            KFImage(url)
                .resizable()
                .cacheOriginalImage()
                .diskCacheExpiration(.days(7))
                .placeholder { PlaceholderView(imageWidth: imageWidth) }
                .scaledToFill()
                .frame(width: imageWidth, height: imageWidth / aspectRatio)
                .clipShape(Rectangle())
        }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .onChange(of: __aspectRatio, initial: true) { _, newAspectRatio in
            self.aspectRatio = newAspectRatio
        }
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
