//
//  ResourceImageViewPager.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI

struct ResourceImageViewPager: View {
    
    public let urls: [URL]
    
    var body: some View {
        TabView {
            ForEach(urls, id: \.self) { url in
                ResourceImageView(url: url)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .aspectRatio(1, contentMode: .fill)
        .background(Color.text)
    }
}

#Preview {
    ResourceImageViewPager(urls: [
        URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/RecipeImages%2Fseared_ribeye_steak.jpg?alt=media&token=38c16213-c053-4f47-992a-5dd748dc529b")!,
        URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2FWhatIsTheCarnivoreDiet.jpg?alt=media&token=66c254f6-6f9a-4240-97f5-726baa84c75b")!
    ])
}
