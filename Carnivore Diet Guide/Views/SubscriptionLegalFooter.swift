//
//  SubscriptionLegalFooter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI

/// Auto-renewal terms plus Terms of Use and Privacy Policy links, shown under the subscribe
/// buttons on every paywall (App Review Guideline 3.1.2).
struct SubscriptionLegalFooter: View {

    @State private var showTermsOfService = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Payment is charged to your Apple Account. Manage or cancel anytime in your App Store account settings.")
                .font(.caption2)
                .foregroundStyle(Color.text.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 24) {
                Button("Terms of Use") {
                    showTermsOfService = true
                }
                .sheet(isPresented: $showTermsOfService) {
                    TextWall(TermsOfService.markdownContent)
                        .presentationDragIndicator(.visible)
                }
                Button("Privacy Policy") {
                    showPrivacyPolicy = true
                }
                .sheet(isPresented: $showPrivacyPolicy) {
                    TextWall(PrivacyPolicy.markdownContent)
                        .presentationDragIndicator(.visible)
                }
            }
            .font(.caption.bold())
            .foregroundStyle(Color.accentColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SubscriptionLegalFooter()
        .padding()
        .background(Color.background)
}
