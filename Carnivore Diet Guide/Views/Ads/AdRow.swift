//
//  AdRow.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import SwiftUI

struct AdRow: View {
    
    @State private var showMarketingView: Bool = false
    
    var body: some View {
        VStack {
            BasicBannerAdView()
                .frame(minHeight: 91)
            RemoveAdsButton()
        }
    }
    
    @ViewBuilder func RemoveAdsButton() -> some View {
        Button {
            showMarketingView = true
        } label: {
            Text("Remove these ads")
                .foregroundStyle(Color.accent)
                .font(.footnote.bold())
                .padding(.horizontal, .paddingHorizontalButtonXSmall)
                .padding(.vertical, .paddingVerticalButtonXSmall)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                        .foregroundStyle(Color.accent.opacity(0.1))
                }
        }
        .fullScreenCover(isPresented: $showMarketingView) {
            MarketingView()
        }
    }
}

#Preview {
    AdRow()
}
