//
//  SubscriptionProductsUnavailableView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI

/// Stands in for the subscribe buttons while the StoreKit products are loading, or when they
/// could not be loaded, so a paywall never shows an empty space where the buttons belong.
struct SubscriptionProductsUnavailableView: View {

    let isLoading: Bool
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                ProgressView()
                Text("Loading subscription options…")
            } else {
                Text("Subscription options couldn't be loaded. Check your connection and try again.")
                Button("Try Again", action: retry)
                    .bold()
                    .foregroundStyle(Color.accentColor)
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.text)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        }
        .padding(.top, 8)
    }
}

#Preview {
    VStack {
        SubscriptionProductsUnavailableView(isLoading: true) { }
        SubscriptionProductsUnavailableView(isLoading: false) { }
    }
    .padding()
    .background(Color.background)
}
