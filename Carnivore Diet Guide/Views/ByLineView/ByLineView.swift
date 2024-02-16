//
//  ByLineView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import SwiftUI

struct ByLineView: View {
    
    private let profileImageSize: CGFloat = 44
    private let profileImagePadding: CGFloat = 2
    
    @State var userId: String
    @StateObject private var model = ByLineViewModel()
    
    var body: some View {
        HStack {
            ProfileImageView(
                model.authorProfilePicUrl,
                size: profileImageSize,
                padding: profileImagePadding
            )
            VStack {
                Text(model.authorFullName)
                    .font(.system(size: 16, weight: .bold))
                    .opacity(0.8)
            }
            Spacer()
        }
        .foregroundStyle(Color.text)
        .redacted(reason: model.loadingAuthor ? [.placeholder] : [])
        .frame(height: profileImageSize)
        .onChange(of: userId, initial: true) { newUserId in
            model.set(userId: newUserId)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ByLineView(userId: "userId")
    }
}
