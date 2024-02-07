//
//  RecipeDetailsHeaderContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import SwiftUI

struct RecipeDetailsHeaderContent: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var body: some View {
        HStack {
            CloseButton()
            Spacer()
            ExtraOptionsButton()
            CommentsButton()
            FavoriteButton()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .text, location: 0.8),
                .init(color: .text, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        ))
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            HeaderButtonLabel("chevron.backward")
        }
    }
    
    @ViewBuilder func FavoriteButton() -> some View {
        Button {
            //TODO: Add ability to favorite recipes
        } label: {
            HeaderButtonLabel("heart")
        }
    }
    
    @ViewBuilder func CommentsButton() -> some View {
        Button {
            //TODO: Add ability to comment on recipes
        } label: {
            HeaderButtonLabel("text.bubble.fill")
        }
    }
    
    @ViewBuilder func ExtraOptionsButton() -> some View {
        Menu {
            ReportRecipeButton()
            EditRecipeButton()
            DeleteRecipeButton()
        } label: {
            HeaderButtonLabel("ellipsis")
        }
    }
    
    @ViewBuilder func ReportRecipeButton() -> some View {
        Button {
            //TODO: Add ability to report recipe
        } label: {
            Label("Report Recipe", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func EditRecipeButton() -> some View {
        Button {
            //TODO: Add ability to edit recipe
        } label: {
            Label("Edit Recipe", systemImage: "pencil")
        }
    }
    
    @ViewBuilder func DeleteRecipeButton() -> some View {
        Button {
            //TODO: Add ability to delete recipe
        } label: {
            Label("Delete Recipe", systemImage: "trash")
        }
    }
    
    @ViewBuilder func HeaderButtonLabel(_ icon: String) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(Color.accent)
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .resizable()
                .bold()
                .foregroundStyle(Color.background)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
        }
    }
}

#Preview {
    RecipeDetailsHeaderContent()
}
