//
//  CommentSectionView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import SwiftUI

struct CommentSectionView: View {
    
    struct Resource: Equatable {
        var id: String
        var type: ResourceType
    }
    
    enum ResourceType {
        case recipe
        case post
    }
    
    private let controlSize: CGFloat = 48
    
    @State var resource: Resource
    
    @StateObject private var model = CommentSectionViewModel()
    @State private var commentText: String = ""
    @FocusState private var isCommentFieldFocused: Bool
    @State private var showSendButton: Bool = false
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    private func sendComment() async -> TaskStatus {
        guard !commentText.isEmpty else { return .failed("Your comment can not be empty") }
        
        do {
            try await model.sendComment(
                text: commentText,
                toResource: resource
            )
            isCommentFieldFocused = false
            commentText = ""
            return .success
        } catch {
            return .failed("Could not send comment: \(error.localizedDescription)")
        }
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }

    var body: some View {
        CommentSectionContent()
            .background(Color.background)
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
            .alert(errorMessage, isPresented: $showError) {}
            .onChange(of: resource, initial: true) { newResource in
                model.startListeningForComments(onResource: newResource)
            }
    }
    
    @ViewBuilder func CommentSectionContent() -> some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(model.comments) { comment in
                        Comment(comment)
                    }
                }
                .padding(.vertical)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 16)
            }
            Spacer()
            CommentControls()
        }
        .overlay {
            if model.comments.isEmpty {
                VStack {
                    Spacer()
                    Text("It's pretty quiet in here.\nBe the first to comment!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.text)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder func Comment(_ comment: Comment) -> some View {
        VStack {
            CommentView(comment: comment)
                .padding(.horizontal)
            Divider()
        }
    }
    
    @ViewBuilder func CommentControls() -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(spacing: 2) {
                CommentTextFieldLabel()
                CommentTextField()
            }
            if showSendButton {
                SendCommentButton()
            }
        }
        .padding()
        .onChange(of: isCommentFieldFocused, initial: true) { isfocused in
            withAnimation(.snappy) {
                showSendButton = isfocused
            }
        }
    }
    
    @ViewBuilder func CommentTextFieldLabel() -> some View {
        HStack {
            Text(showSendButton || commentText.isEmpty ? "Your comment" : "")
                .font(.system(size: 16))
                .foregroundStyle(Color.text.opacity(showSendButton ? 1 : 0.5))
                .offset(
                    x: showSendButton ? 0 : 16,
                    y: showSendButton ? 0 : 36
                )
            Spacer()
        }
        .zIndex(1000)
    }
    
    @ViewBuilder func CommentTextField() -> some View {
        TextEditor(text: $commentText)
            .foregroundStyle(Color.text, Color.accent)
            .scrollContentBackground(.hidden)
            .focused($isCommentFieldFocused)
            .multilineTextAlignment(.leading)
            .frame(height: showSendButton ? 2 * controlSize : controlSize)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .overlay {
                FormFieldOverlay {
                    isCommentFieldFocused = true
                }
            }
            .transition(.move(edge: .leading))
    }
    
    @ViewBuilder func SendCommentButton() -> some View {
        TaskAwareButton {
            await sendComment()
        } label: {
            Image(systemName: "paperplane.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.background)
                .background {
                    RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                        .fill(Color.accent)
                }
        }
        .transition(.asymmetric(
            insertion: .push(from: .trailing),
            removal: .push(from: .leading))
        )
    }
}

#Preview("No Comments") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(CommentProvider.self) {
            let mock = MockCommentProvider()
            mock.comments = []
            return mock
        }
    } content: {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                CommentSectionView(resource: .init(
                    id: "recipeId",
                    type: .recipe
                ))
            }
    }
}

#Preview("Send Succeeds") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                CommentSectionView(resource: .init(
                    id: "recipeId",
                    type: .recipe
                ))
            }
    }
}

#Preview("Send Fails") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(CommentSender.self) {
            let mock = MockCommentSender()
            mock.errorToThrowOnSend = "Test Failure"
            return mock
        }
    } content: {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                CommentSectionView(resource: .init(
                    id: "recipeId",
                    type: .recipe
                ))
            }
    }
}
