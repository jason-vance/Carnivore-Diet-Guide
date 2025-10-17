//
//  OnboardingWelcomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep
    
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
                    reviewAuthor: "R Dizzie"
                )
                SellingPoint(
                    "Awesome Articles",
                    review : "Such a great app for having carnivore diet. I ll use it everyday",
                    reviewAuthor: "Lello9800"
                )
                SellingPoint(
                    "Rockin' Recipes",
                    review : "I love trying out the recipes in this app",
                    reviewAuthor: "mario495"
                )
                SellingPoint(
                    "A strong and growing community of carnivores just like you",
                    review : "This app is simple to use, helps understand what you can and can’t eat. And measures the nutrients which is handy.",
                    reviewAuthor: "Jolemcd"
                )
            }
            .padding(.top, 4)
            Spacer()
            HStack {
                Text("Are you excited to join us?")
                    .font(.headline)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Button {
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
    
    @ViewBuilder private func SellingPoint(_ text: String, review: String, reviewAuthor: String) -> some View {
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
                Review(review, author: reviewAuthor)
            }
        }
    }
    
    @ViewBuilder private func Review(_ text: String, author: String) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.accentColor)
                }
                Text("- \(author)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text("\"\(text)\"")
                .font(.caption)
                .foregroundColor(.text)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    OnboardingWelcomeView(onboardingStep: .constant(.welcome))
}
