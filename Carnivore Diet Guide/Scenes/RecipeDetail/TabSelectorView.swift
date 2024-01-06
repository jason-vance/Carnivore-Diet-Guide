//
//  TabSelectorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import SwiftUI

struct TabSelectorView: View {
    
    struct Tab: Identifiable {
        let id = UUID()
        let title: String
    }
    
    struct TabView: View {
        
        let tab: Tab
        var isSelected: Bool
        
        var body: some View {
            Text(tab.title)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(isSelected ? Color.text : Color.background)
                .padding()
                .background(isSelected ? Color.background : Color.text)
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
    }
    
    let tabs: [Tab]
    @State var selectedTab: Tab? = nil
    
    init(tabs: [Tab]) {
        self.tabs = tabs
        self.selectedTab = tabs[0]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(tabs) { tab in
                    TabView(tab: tab, isSelected: tab.id == selectedTab?.id)
                        .onTapGesture {
                            self.selectedTab = tab
                        }
                }
            }
        }
    }
}

#Preview {
    TabSelectorView(tabs: [
        TabSelectorView.Tab(title: "Ingredients"),
        TabSelectorView.Tab(title: "Steps"),
        TabSelectorView.Tab(title: "Nutritional Info")
    ])
}
