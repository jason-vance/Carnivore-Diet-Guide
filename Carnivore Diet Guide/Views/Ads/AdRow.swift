//
//  AdRow.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import SwiftUI

struct AdRow: View {
    var body: some View {
        VStack {
            BasicBannerAdView()
                .frame(minHeight: 91)
            //TODO: Uncomment this when subscriptions are available
//            RemoveAdsButton()
        }
    }
    
    @ViewBuilder func RemoveAdsButton() -> some View {
        Button {
            //TODO: Show subscription info
        } label: {
            Text("Remove these ads")
                .foregroundStyle(Color.accent)
                .font(.footnote.bold())
                .padding(.horizontal, .paddingHorizontalButtonSmall)
                .padding(.vertical, .paddingVerticalButtonSmall)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                        .foregroundStyle(Color.accent.opacity(0.1))
                }
        }
    }
}

#Preview {
    AdRow()
}
