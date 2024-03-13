//
//  CreateMenu.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI

struct CreateMenu: View {
    
    private let actionButtonSize: CGFloat = 56
    
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
                        WriteArticleButton()
                        CreateRecipeButton()
                        StartDiscussionButton()
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
                        .shadow(color: Color.text, radius: 4)
                }
                .frame(width: actionButtonSize, height: actionButtonSize)
                .padding()
        }
        .rotationEffect(showCreateOptions ? .degrees(135) : .zero)
    }
    
    @ViewBuilder func CreateRecipeButton() -> some View {
        NavigationLink {
            EditRecipeView()
        } label: {
            ActionButtonLabel(
                String(localized: "Create a Recipe"),
                imageName: "frying.pan.fill"
            )
        }
    }
    
    @ViewBuilder func WriteArticleButton() -> some View {
        Button {
            //Add ability to write an article
        } label: {
            ActionButtonLabel(
                String(localized: "Write an Article"),
                imageName: "newspaper.fill"
            )
        }
    }
    
    @ViewBuilder func StartDiscussionButton() -> some View {
        Button {
            //Add ability to start a discussion
        } label: {
            ActionButtonLabel(
                String(localized: "Start a Disussion"),
                imageName: "bubble.left.and.text.bubble.right.fill"
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
        .frame(height: actionButtonSize)
    }
}

#Preview {
    CreateMenu()
}
