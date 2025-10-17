//
//  OnboardingPaywallDiscountView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/17/25.
//

import SwiftUI
import StoreKit

struct OnboardingPaywallDiscountView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep
    let subscriptionManager: SubscriptionLevelProvider

    @State private var products: [String: Product] = [:]
    @State private var isPurchasing: Bool = false
    @State private var showDiscountCodeDialog = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    @State private var showButtons: Bool = false
    
    private var displayProducts: [Product] {
        products
            .map { $0.value }
            .sorted { $0.price < $1.price }
    }
    
    private func doPurchase(productId: String) {
        Task {
            isPurchasing = true
            do {
                let _ = try await subscriptionManager.purchase(productId: productId)
            } catch {
                if let subError = error as? SubscriptionError {
                    errorMessage = subError.message
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
            isPurchasing = false
        }
    }
    
    private func handleOfferCodeCompletion() {
        Task {
            isPurchasing = true
            let _ = await subscriptionManager.isSubscribed()
            isPurchasing = false
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                let _ = await subscriptionManager.isSubscribed()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Limited Time Offer!")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("We think you'll love Carnivore+")
                    .font(.title)
                    .foregroundColor(.text.opacity(0.5))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("Start your 30 day free trial in the next 24 hours and lock in a 75% discount!")
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Add a blinking timer or something
            Spacer()
            if showButtons {
                SubscribeButtons()
            }
            Button {
                onboardingStep = onboardingStep.skip
            } label: {
                Text("Maybe Later")
                    .foregroundColor(Color.accentColor.opacity(0.7))
            }
            .padding(.top)
        }
        .padding()
        .background(Color.background)
        .overlay { IsPurchasingView() }
        .animation(.snappy, value: showButtons)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showButtons = true
            }
        }
        .onReceive(subscriptionManager.$discountProducts) { products in
            self.products = products
        }
        .alert(
            "Purchase Error",
            isPresented: $showError,
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(errorMessage ?? "An unknown error occurred") }
        )
    }
    
    @ViewBuilder private func IsPurchasingView() -> some View {
        if isPurchasing {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
        }
    }
    
    @ViewBuilder func SubscribeButtons() -> some View {
        VStack {
            ForEach(displayProducts, id: \.self) { product in
                SubscribeButton(product: product)
            }
            DiscountCodeButton()
        }
    }
    
    @ViewBuilder private func SubscribeButton(product: Product) -> some View {
        Button {
            doPurchase(productId: product.id)
        } label: {
            HStack(spacing: 0) {
                Text(product.displayName)
                    .bold()
                    .fontWidth(.condensed)
                Spacer(minLength: 0)
                Text(product.displayPrice)
                    .bold()
                if let period = product.subscription?.subscriptionPeriod.unit.localizedDescription {
                    Text("/\(period.lowercased())")
                        .font(.caption2)
                }
            }
            .foregroundStyle(Color.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color.accentColor.gradient)
            }
        }
        .disabled(isPurchasing)
        .padding(.top, 8)
    }
    
    @ViewBuilder private func DiscountCodeButton() -> some View {
        Button("Enter Discount Code") {
            showDiscountCodeDialog = true
        }
        .foregroundColor(.accentColor)
        .offerCodeRedemption(isPresented: $showDiscountCodeDialog) { result in
            handleOfferCodeCompletion()
        }
        .padding(.top)
    }
}

#Preview {
    OnboardingPaywallDiscountView(onboardingStep: .constant(.welcome), subscriptionManager: .instance)
}
