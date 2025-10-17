//
//  OnboardingGoalReviewView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI

struct OnboardingGoalReviewView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep
    
    @Binding var whyCarnivore: WhyCarnivore?
    
    static let textItems = [
        "You can do it! And we will help.",
        "We believe in you! You can do anything.",
        "You're amazing! Don't let them tell you otherwise.",
        "Please help all of us hit our goals too!"
    ]
    @State private var showItems: [Bool] = Array(repeating: false, count: textItems.count)
    
    var body: some View {
        VStack {
            HStack {
                Text("Your goal:")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("\"\(whyCarnivore?.value ?? "")\"")
                    .font(.largeTitle.bold())
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("Excellent! The Carnivore Diet Guide can definitely help you with that.")
                    .font(.title)
                    .foregroundColor(.text.opacity(0.5))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Affirmations()
            Spacer()
            Button {
                onboardingStep = onboardingStep.next
            } label: {
                Text("Here's to a better me!")
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
    
    @ViewBuilder private func Affirmations() -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(Array(Self.textItems.enumerated()), id: \.offset) { index, item in
                    // Only show the Text if our state property is true
                    HStack {
                        let corners = RectangleCornerRadii(
                            topLeading: .cornerRadiusMedium,
                            bottomLeading: index % 2 == 0 ? .cornerRadiusMedium : 0,
                            bottomTrailing: index % 2 == 0 ? 0 : .cornerRadiusMedium,
                            topTrailing: .cornerRadiusMedium
                        )
                        
                        if index % 2 == 0 {
                            Spacer()
                        }
                        Text(item)
                            .foregroundStyle(Color.accentColor)
                            .font(.headline)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(UnevenRoundedRectangle(cornerRadii: corners, style: .continuous))
                        if index % 2 == 1 {
                            Spacer()
                        }
                    }
                    .opacity(showItems[index] ? 1 : 0) // Animate opacity
                    .offset(y: showItems[index] ? 0 : 20) // Animate offset
                    .animation(.easeOut(duration: 0.5).delay(0.5 + Double(index) * 0.5), value: showItems[index])
                    .transition(.opacity.combined(with: .offset(y: 20))) // Optional: for initial appearance
                    .onAppear {
                        showItems[index] = true
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingGoalReviewView(onboardingStep: .constant(.goalPrompt), whyCarnivore: .constant(.none))
}
