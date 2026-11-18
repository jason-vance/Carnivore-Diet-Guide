//
//  OnboardingWelcomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealsSellingPoints = false

    var body: some View {
        VStack {
            HStack {
                Text("Welcome to the Carnivore Diet Guide")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("We are excited to have you!")
                    .font(.title)
                    .foregroundColor(.text.opacity(0.5))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("You are a few taps away from:")
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.top, 12)
            VStack(spacing: 8) {
                SellingPoint(
                    "Great Guides",
                    review : "Great for beginners",
                    reviewAuthor: "R Dizzie",
                    index: 0
                )
                SellingPoint(
                    "Awesome Articles",
                    review : "Such a great app for having carnivore diet. I ll use it everyday",
                    reviewAuthor: "Lello9800",
                    index: 1
                )
                SellingPoint(
                    "Rockin' Recipes",
                    review : "I love trying out the recipes in this app",
                    reviewAuthor: "mario495",
                    index: 2
                )
            }
            .padding(.top, 4)
            .onAppear { revealsSellingPoints = true }
            Spacer()
            HStack {
                Text("Are you excited to join us?")
                    .font(.headline)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Button {
                Haptics.tap()
                onboardingStep = onboardingStep.next
            } label: {
                Text("I'm Excited!")
                    .foregroundColor(Color.background)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                            .foregroundStyle(Color.accentColor.gradient)
                    }
            }
        }
        .padding()
        .background(Color.background)
    }
    
    /// Each selling point slides in after the last, and its stars pop in one by one.
    private func revealAnimation(index: Int, delay: Double = 0) -> Animation? {
        guard !reduceMotion else { return nil }
        return .spring(response: 0.4, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.25 + delay)
    }

    @ViewBuilder private func SellingPoint(_ text: String, review: String, reviewAuthor: String, index: Int) -> some View {
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
                Review(review, author: reviewAuthor, index: index)
            }
        }
        .opacity(revealsSellingPoints ? 1 : 0)
        .offset(y: revealsSellingPoints ? 0 : 16)
        .animation(revealAnimation(index: index), value: revealsSellingPoints)
    }

    @ViewBuilder private func Review(_ text: String, author: String, index: Int) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.accentColor)
                        .scaleEffect(revealsSellingPoints ? 1 : 0.2)
                        .animation(
                            revealAnimation(index: index, delay: 0.15 + Double(star) * 0.06)?.speed(1.4),
                            value: revealsSellingPoints
                        )
                }
                Text("- \(author)")
                    .font(.caption.bold())
                    .foregroundStyle(Color.text.opacity(0.6))
                Spacer()
            }
            Text("\"\(text)\"")
                .font(.caption)
                .foregroundColor(.text)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    OnboardingWelcomeView(onboardingStep: .constant(.welcome))
}
