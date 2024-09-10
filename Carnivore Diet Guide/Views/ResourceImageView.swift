//
//  ResourceImageView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI
import Kingfisher

struct ResourceImageView: View {
    
    private class ResourceImageModifier: ImageModifier {
        
        let aspectRatio: CGFloat
        
        init(aspectRatio: CGFloat) {
            self.aspectRatio = aspectRatio
        }
        
        func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage {
            guard let image = image.scaledToFill(aspectRatio: aspectRatio) else {
                return image
            }
            return image
        }
    }
    
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
        KFImage(url)
            .resizable()
            .cacheOriginalImage()
            .diskCacheExpiration(.days(7))
            .imageModifier(ResourceImageModifier(aspectRatio: aspectRatio))
            .placeholder { PlaceholderView() }
            .aspectRatio(aspectRatio, contentMode: .fill)
            .onChange(of: __aspectRatio, initial: true) { _, newAspectRatio in
                self.aspectRatio = newAspectRatio
            }
    }
    
    @ViewBuilder func PlaceholderView() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.text.opacity(0.8))
            Image(systemName: "photo")
                .foregroundStyle(Color.background)
        }
    }
}


#Preview {
    ResourceImageView(url: FeedItem.samplePost.imageUrls[0])
}
