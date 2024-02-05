//
//  ProfileControlLabel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI

struct ProfileControlLabel: View {
    
    @State var title: String
    @State var icon: String
    @State var showNavigationAccessories: Bool
    
    init(_ title: String, icon: String, showNavigationAccessories: Bool) {
        self.title = title
        self.icon = icon
        self.showNavigationAccessories = showNavigationAccessories
    }
    
    var body: some View {
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
    ProfileControlLabel("Settings", icon: "gearshape", showNavigationAccessories: true)
}
