//
//  CommentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import SwiftUI

struct CommentView: View {
    
    private let profileImageSize: CGFloat = 44
    private let profileImagePadding: CGFloat = 2
    
    @State var comment: Comment
    @StateObject var model = CommentViewModel()
    
    var body: some View {
        VStack {
            HStack {
                ProfileImageView(
                    model.userImageUrl,
                    size: profileImageSize,
                    padding: profileImagePadding
                )
                .redacted(reason: model.isLoading ? [.placeholder] : [] )
                VStack {
                    Text(model.userFullName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: model.isLoading ? [.placeholder] : [] )
                    Text(model.dateString)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0.8)
                }
            }
            .overlay(alignment: .topTrailing) {
                OptionsButton()
            }
            Text(model.commentText)
                .font(.system(size: 16))
                .foregroundStyle(Color.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .onAppear {
            model.comment = comment
        }
    }
    
    @ViewBuilder func OptionsButton() -> some View {
        Menu {
            Text(model.commentText)
            //TODO: Show report button if comment belongs to other users
            ReportCommentButton()
            //TODO: Show delete button if comment belongs to user
            DeleteCommentButton()
        } label: {
            Image(systemName: "ellipsis")
                .padding()
        }
    }
    
    @ViewBuilder func ReportCommentButton() -> some View {
        Button {
            //TODO: Add ability to report comment
        } label: {
            Label("Report", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func DeleteCommentButton() -> some View {
        Button {
            //TODO: Add ability to delete comment
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CommentView(comment: .sample)
            .padding()
    }
}
