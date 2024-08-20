//
//  CreatePostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct CreatePostView: View {
    
    @StateObject private var model = CreatePostViewModel()
    
    var body: some View {
        VStack {
            ScreenTitleBar(String(localized: "Create Post"))
            Spacer()
        }
        .background(Color.background)
    }
}

#Preview {
    CreatePostView()
}
