//
//  UserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI
import Kingfisher

struct UserProfileView: View {
    
    @State private var showLogoutDialog: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func confirmedLogout() {
        //authProvider.logout()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBar()
                ScrollView {
                    VStack {
                        ProfileImage()
                        FullName()
                        Username()
                        AccountInformationButton()
//                        FavoriteRecipesButton()
//                        BookmarkedArticlesButton()
//                        SettingsButton()
                        LogoutButton()
                    }
                    .padding()
                }
            }
            .background(Color.background)
        }
        .alert(errorMessage, isPresented: $showError) {}
        .confirmationDialog(
            "Are you sure you want to logout?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            ConfirmLogoutButton()
            CancelLogoutButton()
        }
    }
    
    @ViewBuilder func ConfirmLogoutButton() -> some View {
        Button(role: .destructive) {
            confirmedLogout()
        } label: {
            Text("Logout")
        }
    }
    
    @ViewBuilder func CancelLogoutButton() -> some View {
        Button(role: .cancel) {
        } label: {
            Text("Cancel")
        }
        
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Rectangle()
            .foregroundStyle(Color.accent)
            .frame(height: 64)
            .overlay(alignment: .top) {
                TitleView()
            }
            .background(Color.accent)
    }
    
    @ViewBuilder func TitleView() -> some View {
        VStack(spacing: 0) {
            Text("Profile")
                .font(.system(size: 48, weight: .black))
        }
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func ProfileImage() -> some View {
        KFImage(URL(string: "https://images.theconversation.com/files/453023/original/file-20220318-13-f1w6ml.jpg?ixlib=rb-1.1.0&rect=0%2C528%2C7360%2C3680&q=45&auto=format&w=1356&h=668&fit=crop")!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .frame(width: 200, height: 200)
            .padding(4)
            .background(Circle().fill(Color.text))
    }
    
    @ViewBuilder func FullName() -> some View {
        Text("Dave McMeaterton")
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func Username() -> some View {
        Text("mcMeat")
            .font(.system(size: 18))
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func AccountInformationButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Account Information"),
            icon: "person.fill"
        ) {
            Text("Account Information")
        }
    }
    
    @ViewBuilder func FavoriteRecipesButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Favorite Recipes"),
            icon: "heart.fill"
        ) {
            Text("Favorite Recipes")
        }
    }
    
    @ViewBuilder func BookmarkedArticlesButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Bookmarked Articles"),
            icon: "bookmark.fill"
        ) {
            Text("Favorites")
        }
    }
    
    @ViewBuilder func SettingsButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Settings"),
            icon: "gearshape.fill"
        ) {
            Text("Settings")
        }
    }
    
    @ViewBuilder func LogoutButton() -> some View {
        ProfileButton(
            String(localized: "Logout"),
            icon: "iphone.and.arrow.forward"
        ) {
            showLogoutDialog = true
        }
        .padding(.top, 32)
    }
    
    @ViewBuilder func ProfileNavigationLink<Content>(
        _ title: String,
        icon: String,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        NavigationLink {
            content()
        } label: {
            ProfileControlLabel(title, icon: icon, showNavigationAccessories: true)
        }
    }
    
    @ViewBuilder func ProfileButton(
        _ title: String,
        icon: String,
        action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            ProfileControlLabel(title, icon: icon, showNavigationAccessories: false)
        }
    }
    
    @ViewBuilder func ProfileControlLabel(
        _ title: String,
        icon: String,
        showNavigationAccessories: Bool
    ) -> some View {
        HStack {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(width: 24, height: 24)
            Text(title)
                .font(.system(size: 18, weight: .bold))
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .bold))
                .opacity(showNavigationAccessories ? 1 : 0)
        }
        .foregroundStyle(Color.text)
        .frame(height: 48)
        .overlay(alignment: .bottom) {
            Rectangle()
                .foregroundStyle(Color.text)
                .frame(height: 1)
                .opacity(showNavigationAccessories ? 0.1 : 0)
        }
    }
}

#Preview {
    UserProfileView()
}
