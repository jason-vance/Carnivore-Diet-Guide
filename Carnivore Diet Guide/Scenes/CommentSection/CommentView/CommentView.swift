//
//  CommentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import SwiftUI

struct CommentView: View {
    
    private let profileImageSize: CGFloat = 28
    private let profileImagePadding: CGFloat = 2
    
    @State var comment: Comment
    @State var resource: Resource
    @StateObject var model = CommentViewModel()
    
    var body: some View {
        VStack {
            VStack {
                CommentHeader()
                CommentBody()
            }
            .padding(.horizontal)
            Divider()
        }
        .overlay {
            if model.showError {
                ErrorOverlay()
            }
        }
        .onAppear {
            model.set(comment: comment, resource: resource)
        }
    }
    
    @ViewBuilder func ErrorOverlay() -> some View {
        Text(model.errorMessage)
            .foregroundStyle(Color.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.text)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.snappy.delay(1)) {
                    model.showError = false
                }
            }
    }
    
    @ViewBuilder func CommentHeader() -> some View {
        HStack {
            ProfileImageView(
                model.userImageUrl,
                size: profileImageSize,
                padding: profileImagePadding
            )
            .redacted(reason: model.isLoading ? [.placeholder] : [] )
            VStack {
                Text(model.userFullName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .redacted(reason: model.isLoading ? [.placeholder] : [] )
                Text(model.dateString)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.8)
            }
        }
        .overlay(alignment: .topTrailing) {
            OptionsButton()
        }
    }
    
    @ViewBuilder func OptionsButton() -> some View {
        Menu {
            Text(model.commentText)
            if model.commentIsMine {
                DeleteCommentButton()
            } else {
                ReportCommentButton()
            }
        } label: {
            Image(systemName: "ellipsis")
                .padding()
        }
    }
    
    @ViewBuilder func ReportCommentButton() -> some View {
        Button {
            model.reportComment()
        } label: {
            Label("Report", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func DeleteCommentButton() -> some View {
        Button {
            model.deleteComment()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder func CommentBody() -> some View {
        Text(model.commentText)
            .font(.system(size: 16))
            .foregroundStyle(Color.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
}

#Preview("Default") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CommentView(
            comment: .sample,
            resource: .sample
        )
        .padding()
    }
}

#Preview("Comments belonging to me and others") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(CommentProvider.self) {
            let mock = MockCommentProvider()
            mock.comments = [
                .init(
                    id: UUID().uuidString,
                    userId: "myId",
                    text: "This is my comment",
                    date: .now
                ),
                .init(
                    id: UUID().uuidString,
                    userId: UUID().uuidString,
                    text: "This is somebody else's comment",
                    date: .now
                )
            ]
            return mock
        }
        
        iocContainer.autoregister(CurrentUserIdProvider.self) {
            let mock = MockCurrentUserIdProvider()
            mock.currentUserId = "myId"
            return mock
        }
    } content: {
        CommentSectionView(resource: .sample)
    }
}

#Preview("Delete/Report Fails") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(CommentProvider.self) {
            let mock = MockCommentProvider()
            mock.comments = [
                .init(
                    id: UUID().uuidString,
                    userId: "myId",
                    text: "This is my comment",
                    date: .now
                ),
                .init(
                    id: UUID().uuidString,
                    userId: UUID().uuidString,
                    text: "This is somebody else's comment",
                    date: .now
                )
            ]
            return mock
        }
        
        iocContainer.autoregister(CurrentUserIdProvider.self) {
            let mock = MockCurrentUserIdProvider()
            mock.currentUserId = "myId"
            return mock
        }
        
        iocContainer.autoregister(CommentDeleter.self) {
            let mock = MockCommentDeleter()
            mock.error = "Test Failure"
            return mock
        }
        
        iocContainer.autoregister(CommentReporter.self) {
            let mock = MockCommentReporter()
            mock.error = "Test Failure"
            return mock
        }
    } content: {
        CommentSectionView(resource: .sample)
    }
}
