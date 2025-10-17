//
//  OnboardingBeforeAndAfterView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI

struct OnboardingBeforeAndAfterView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep
    
    static let subscriberBullets = [
        "Confident in their dietary choices",
        "Knowledgable of the latest research",
        "More likely to reach their health goals",
        "Members of an active community of carivores",
        "Able to access premium articles and recipes"
    ]
    
    static let nonSubscriberBullets = [
        "Unsure of the best foods to eat",
        "Wonders about the latest research",
        "Less likely to reach their health goals",
        "Searching for their carivore tribe",
        "Unable to access premium articles and recipes",
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("You're in the right place to support your carnivore journey")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Spacer()
            HStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("Everyone Else")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.accentColor.opacity(0.5))
                    ForEach(Self.nonSubscriberBullets, id: \.self) { bullet in
                        bulletPoint(bullet, isPositive: false)
                    }
                }
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.accentColor.opacity(0.1))
                }
                VStack(spacing: 12) {
                    Text("Carnivore+ Subscribers")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.accentColor)
                    ForEach(Self.subscriberBullets, id: \.self) { bullet in
                        bulletPoint(bullet, isPositive: true)
                    }
                    bulletPoint("And more!", isPositive: true)
                }
                .padding(8)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .foregroundStyle(Color.background)
                            .shadow(color: Color.black.opacity(0.6), radius: 4)
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .stroke(Color.accentColor, style: .init(lineWidth: 2))
                    }
                }
            }
            .padding(.bottom)
            Spacer()
            Button {
                onboardingStep = onboardingStep.next
            } label: {
                Text("Try 30 days for free!")
                    .foregroundColor(Color.background)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                            .foregroundStyle(Color.accentColor.gradient)
                    }
            }
            Button {
                onboardingStep = onboardingStep.skip
            } label: {
                Text("Skip")
                    .foregroundColor(Color.accentColor.opacity(0.7))
            }
        }
        .padding()
        .background(Color.background)
    }
    
    @ViewBuilder private func bulletPoint(
        _ text: String,
        isPositive: Bool
    ) -> some View {
        HStack(alignment: .top) {
            Image(systemName: isPositive ? "plus.circle.fill" : "minus.circle.fill")
                .font(.footnote)
                .foregroundStyle(isPositive ? Color.accentColor : Color.accentColor.opacity(0.5))
                .offset(y: 1)
            Text(text)
                .font(.footnote.bold())
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    OnboardingBeforeAndAfterView(onboardingStep: .constant(.welcome))
}
