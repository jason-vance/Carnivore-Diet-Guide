//
//  HomeMenuBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/19/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeMenuBar: View {
    
    public static let height: CGFloat = 44
    
    enum HomeMenuTab {
        case knowledge
        case program
        case recipes
        case profile
    }

    @Binding public var selectedTab: HomeMenuTab
    @Binding public var profileImageUrl: URL?

    @ObservedObject private var programStore = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self

    /// A dot on the 30 Days tab when today's check-in is waiting.
    private var showProgramBadge: Bool {
        programStore.needsCheckInToday(isSubscribed: subscriptionManager.subscriptionLevel == .carnivorePlus)
    }

    var body: some View {
        HStack {
            KnowledgeMenuItem()
            Spacer()
            ProgramMenuItem()
            Spacer()
            RecipesMenuItem()
            Spacer()
            ProfileMenuItem()
        }
        .padding(.top, 4)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .background(Color.background)
        .overlay(alignment: .top) { BarDivider() }
    }
    
    @ViewBuilder func KnowledgeMenuItem() -> some View {
        let image = selectedTab == .knowledge ? "house.fill" : "house"
        MenuItem(.knowledge, text: String(localized: "Home"), image: { MenuItemImage(image) }) {
            selectedTab = .knowledge
        }
    }
    
    @ViewBuilder func ProgramMenuItem() -> some View {
        let image = selectedTab == .program ? "list.bullet.clipboard.fill" : "list.bullet.clipboard"
        MenuItem(.program, text: String(localized: "30 Days"), image: {
            MenuItemImage(image)
                .overlay(alignment: .topTrailing) {
                    if showProgramBadge {
                        Circle()
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -2)
                            .accessibilityHidden(true)
                    }
                }
        }) {
            selectedTab = .program
        }
        .accessibilityValue(showProgramBadge ? Text("Check-in waiting") : Text(""))
    }

    @ViewBuilder func RecipesMenuItem() -> some View {
        let image = selectedTab == .recipes ? "frying.pan.fill" : "frying.pan"
        MenuItem(.recipes, text: String(localized: "Recipes"), image: { MenuItemImage(image) }) {
            selectedTab = .recipes
        }
    }
    
    @ViewBuilder func ProfileMenuItem() -> some View {
        MenuItem(.profile, text: String(localized: "Profile"), image: ProfileImage) {
            selectedTab = .profile
        }
    }
    
    @ViewBuilder func MenuItem<Content:View>(
        _ tab: HomeMenuTab,
        text: String,
        image: () -> Content,
        onSelected: @escaping () -> ()
    ) -> some View {
        Button {
            onSelected()
        } label: {
            VStack(spacing: 0) {
                image()
                    .frame(width: 32, height: 32)
                MenuItemText(text)
            }
            .foregroundStyle(Color.text)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func ProfileImage() -> some View {
        ProfileImageView(profileImageUrl, size: 28, padding: 2)
    }
    
    @ViewBuilder func MenuItemImage(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20))
    }
    
    @ViewBuilder func MenuItemText(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(HomeMenuBar.HomeMenuTab.knowledge) { selectedTab in
            Rectangle()
                .overlay(alignment: .bottom) {
                    HomeMenuBar(
                        selectedTab: selectedTab,
                        profileImageUrl: .constant(UserData.sample.profileImageUrl)
                    )
                }
        }
    }
}
