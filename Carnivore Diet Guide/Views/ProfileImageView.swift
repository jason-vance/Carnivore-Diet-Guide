//
//  ProfileImageView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    
    var profileImageUrl: URL?
    var size: CGFloat?
    var padding: CGFloat
    
    var imageSize: CGFloat? {
        guard let size = size else { return nil }
        return size - (2 * padding)
    }
    
    init(_ url: URL?, size: CGFloat? = 200, padding: CGFloat = 4) {
        self.profileImageUrl = url
        self.size = size
        self.padding = padding
    }

    var body: some View {
        KFImage(profileImageUrl)
            .resizable()
            .cacheOriginalImage()
            .diskCacheExpiration(.days(7))
//            .forceRefresh()
            .placeholder(PlaceholderView)
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(Circle())
            .padding(padding)
            .background(Circle().fill(Color.text))
    }
    
    @ViewBuilder func PlaceholderView() -> some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundStyle(Color.background)
            .clipShape(Circle())
    }
}

#Preview("Non-placeholder") {
    ProfileImageView(URL(string: "https://images.theconversation.com/files/453023/original/file-20220318-13-f1w6ml.jpg?ixlib=rb-1.1.0&rect=0%2C528%2C7360%2C3680&q=45&auto=format&w=1356&h=668&fit=crop")!)
}

#Preview("Placeholder") {
    ProfileImageView(nil)
}
