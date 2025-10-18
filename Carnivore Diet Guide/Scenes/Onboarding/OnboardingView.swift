//
//  OnboardingView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/11/25.
//

import SwiftUI
import SwinjectAutoregistration
import StoreKit

struct OnboardingView: View {
    
    enum OnboardingStep {
        case welcome
        case goalPrompt
        case goalReview
        case beforeAndAfter
        case paywall
        case paywallDiscount
        case finished
        
        var next: OnboardingStep {
            switch self {
            case .welcome:
                    .goalPrompt
            case .goalPrompt:
                    .goalReview
            case .goalReview:
                    .beforeAndAfter
            case .beforeAndAfter:
                    .paywall
            case .paywall:
                    .paywallDiscount
            case .paywallDiscount:
                    .finished
            case .finished:
                    .finished
            }
        }
        
        var skip: OnboardingStep {
            switch self {
            case .welcome:
                    .goalPrompt
            case .goalPrompt:
                    .beforeAndAfter
            case .goalReview:
                    .beforeAndAfter
            case .beforeAndAfter:
                    .paywall
            case .paywall:
                    .paywallDiscount
            case .paywallDiscount:
                    .finished
            case .finished:
                    .finished
            }
        }
    }
    
    @Environment(\.presentationMode) private var presentationMode
    
    private let subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    
    @State private var onboardingStep: OnboardingStep = .welcome
    
    @State private var whyCarnivore: WhyCarnivore? = nil
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func promptForReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    var body: some View {
        ZStack {
            switch onboardingStep {
            case .welcome:
                OnboardingWelcomeView(onboardingStep: $onboardingStep)
                    .slideUpTransition()
            case .goalPrompt:
                OnboardingGoalPromptView(onboardingStep: $onboardingStep, whyCarnivore: $whyCarnivore)
                    .slideUpTransition()
            case .goalReview:
                OnboardingGoalReviewView(onboardingStep: $onboardingStep, whyCarnivore: $whyCarnivore)
                    .slideUpTransition()
            case .beforeAndAfter:
                OnboardingBeforeAndAfterView(onboardingStep: $onboardingStep)
                    .slideUpTransition()
            case .paywall:
                OnboardingPaywallView(onboardingStep: $onboardingStep, subscriptionManager: subscriptionManager)
                    .slideUpTransition()
            case .paywallDiscount:
                OnboardingPaywallDiscountView(onboardingStep: $onboardingStep, subscriptionManager: subscriptionManager)
                    .slideUpTransition()
            case .finished:
                OnboardingFinishedView()
                    .slideUpTransition()
            }
        }
        .animation(.snappy, value: onboardingStep)
        .onAppear {
            subscriptionManager.refreshProducts()
        }
        .onReceive(subscriptionManager.subscriptionLevelPublisher) { level in
            if level == .carnivorePlus {
                onboardingStep = .finished
            }
        }
    }
    
    @ViewBuilder private func OnboardingFinishedView() -> some View {
        Rectangle()
            .foregroundStyle(Color.accentColor)
            .ignoresSafeArea()
            .onAppear { dismiss() }
            .onAppear { promptForReview() }
    }
}

fileprivate extension View {
    func slideUpTransition() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .bottom).animation(.easeInOut),
            removal: .move(edge: .top).animation(.easeInOut)
        ))
    }
}

#Preview {
    OnboardingView()
}
