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
    
    @State private var animateTimer: Bool = false
    @State private var timeRemaining: String = "..."
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var displayProducts: [Product] {
        products
            .map { $0.value }
            .sorted { $0.price < $1.price }
    }
    
    private var limitedTimeOfferEndDate: Date? {
        // 86400 seconds = 24 hours
        return subscriptionManager.limitedTimeOfferStartDate?.addingTimeInterval(86400)
    }
    
    private func updateRemainingTime() {
        guard let targetDate = limitedTimeOfferEndDate else {
            timeRemaining = "..."
            return
        }
        
        let now = Date()
        
        // Calculate the interval between now and the target date
        let remaining = targetDate.timeIntervalSince(now)
        
        if remaining > 0 {
            // We have time left, so format it
            timeRemaining = format(duration: remaining)
        } else {
            // Countdown has finished
            timeRemaining = "00:00:00"
            timer.upstream.connect().cancel() // Optional: Stop the timer
        }
    }
    
    private func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional // Gives "HH:MM:SS"
        formatter.zeroFormattingBehavior = .pad // Adds leading zeros, e.g., "01" vs "1"
        
        return formatter.string(from: duration) ?? "00:00:00"
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
            CountdownTimerView()
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
            subscriptionManager.limitedTimeOfferStartDate = .now
        }
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
        .onReceive(timer) { _ in updateRemainingTime() }
        .onAppear { updateRemainingTime() }
    }
    
    @ViewBuilder private func IsPurchasingView() -> some View {
        if isPurchasing {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
        }
    }
    
    @ViewBuilder private func CountdownTimerView() -> some View {
        VStack {
            Spacer()
            Text(timeRemaining)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.accentColor)
            Text("To lock in 75% off")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            Spacer()
        }
        .padding()
        .frame(minWidth: 225)
        .background {
            Circle()
                .stroke(style: .init(lineWidth: 8))
                .foregroundStyle(Color.accentColor)
                .opacity(animateTimer ? 0.3 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: animateTimer
                )
                .onAppear { animateTimer = true }
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
    OnboardingPaywallDiscountView(onboardingStep: .constant(.welcome), subscriptionManager: .instance)
}
