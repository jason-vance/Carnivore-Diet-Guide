//
//  CommentSectionView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import SwiftUI

struct CommentSectionView: View {
    
    private let controlSize: CGFloat = 48
    
    @StateObject private var model = CommentSectionViewModel()
    @State private var commentText: String = ""
    @FocusState private var isCommentFieldFocused: Bool
    @State private var showSendButton: Bool = false

    var body: some View {
        CommentSectionContent()
            .background(Color.background)
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
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
    }
    
    @ViewBuilder func Comment(_ comment: Comment) -> some View {
        VStack {
            CommentView(comment: comment)
                .padding(.horizontal)
            Divider()
        }
    }
    
    @ViewBuilder func CommentControls() -> some View {
        //TODO: Spin while comment is sending
        HStack(alignment: .bottom, spacing: 8) {
            VStack(spacing: 2) {
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
        Button {
            isCommentFieldFocused = false
            commentText = ""
            //TODO: Send the comment
        } label: {
            Image(systemName: "paperplane.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.background)
                .padding()
                .frame(width: controlSize, height: controlSize)
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

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                CommentSectionView()
            }
    }
}
