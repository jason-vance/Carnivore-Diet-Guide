//
//  OnboardingPaywallView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI
import SwinjectAutoregistration
import StoreKit

struct OnboardingPaywallView: View {
    
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
                Text("Become a Carnivore+ subscriber for amazing benefits!")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("The first 30 days are free!")
                    .font(.title)
                    .foregroundColor(.text.opacity(0.5))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            VStack(spacing: 8) {
                SellingPoint("Access premium content and tools")
                SellingPoint("Achieve your health goals faster")
                SellingPoint("Enjoy an ad free experience")
                SellingPoint("Premium articles and guides")
                SellingPoint("Cook up premium recipes")
                SellingPoint("Join a strong, growing community")
                SellingPoint("And much more!")
            }
            .padding(.top, 4)
            Spacer()
            HStack {
                Text("Start your 30 day free trial in the next 24 hours and lock in a 75% discount!")
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
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
        .onAppear { subscriptionManager.limitedTimeOfferStartDate = .now }
        .onReceive(subscriptionManager.$discountProducts) { p in products = p }
        .alert(
            "Purchase Error",
            isPresented: $showError,
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(errorMessage ?? "An unknown error occurred") }
        )
    }
    
    @ViewBuilder private func SellingPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "circle")
                .font(.caption2.bold())
                .foregroundStyle(Color.accentColor)
                .offset(y: 4)
            VStack {
                HStack {
                    Text(text)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        }
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
                Spacer(minLength: 0)
                Text(product.displayPrice)
                    .bold()
                if let period = product.subscription?.subscriptionPeriod.unit.localizedDescription {
                    Text("/\(period.lowercased())")
                        .font(.caption2)
                        .fontWidth(.compressed)
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
    OnboardingPaywallView(onboardingStep: .constant(.welcome), subscriptionManager: .instance)
}
