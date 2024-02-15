//
//  CreateMenu.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI

struct CreateMenu: View {
    
    private let actionButtonSize: CGFloat = 64
    
    @State var showCreateOptions: Bool = false
    
    func toggleShowCreateOptions() {
        withAnimation(.snappy) {
            showCreateOptions.toggle()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            BackgroundGradient()
            VStack(alignment: .trailing) {
                if showCreateOptions {
                    Group {
                        CreateRecipeButton()
                        WriteArticleButton()
                        PostToFeedButton()
                    }
                    .transition(.asymmetric(
                        insertion: .push(from: .trailing),
                        removal: .push(from: .leading))
                    )
                }
                FloatingAddButton()
            }
        }
    }
    
    @ViewBuilder func BackgroundGradient() -> some View {
        LinearGradient(
            colors: [Color.text, Color.clear],
            startPoint: .bottomTrailing,
            endPoint: .topLeading
        )
        .transition(.asymmetric(
            insertion: .push(from: .trailing),
            removal: .push(from: .leading))
        )
        .ignoresSafeArea()
        .onTapGesture {
            toggleShowCreateOptions()
        }
        .opacity(showCreateOptions ? 1 : 0)
    }
    
    @ViewBuilder func FloatingAddButton() -> some View {
        Button {
            toggleShowCreateOptions()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .foregroundStyle(Color.background)
                .bold()
                .padding()
                .background {
                    Circle()
                        .fill(Color.accent)
                }
                .frame(width: actionButtonSize, height: actionButtonSize)
                .padding()
        }
        .rotationEffect(showCreateOptions ? .degrees(45) : .zero)
    }
    
    @ViewBuilder func PostToFeedButton() -> some View {
        Button {
            //TODO: Add ability to post to feed
        } label: {
            ActionButtonLabel(
                String(localized: "Post to Feed"),
                imageName: "paperplane.fill"
            )
        }
    }
    
    @ViewBuilder func CreateRecipeButton() -> some View {
        Button {
            //TODO: Add ability to create a recipe
        } label: {
            ActionButtonLabel(
                String(localized: "Create a Recipe"),
                imageName: "frying.pan.fill"
            )
        }
    }
    
    @ViewBuilder func WriteArticleButton() -> some View {
        Button {
            //TODO: Add ability to write an article
        } label: {
            ActionButtonLabel(
                String(localized: "Write an Article"),
                imageName: "newspaper.fill"
            )
        }
    }
    
    @ViewBuilder func ActionButtonLabel(_ text: String, imageName: String) -> some View {
        Label(text, systemImage: imageName)
        .foregroundStyle(Color.background)
        .bold()
        .padding()
        .background {
            Capsule(style: .continuous)
                .fill(Color.accent)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CreateMenu()
}
