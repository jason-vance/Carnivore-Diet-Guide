//
//  OnboardingGoalPromptView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/16/25.
//

import SwiftUI

struct OnboardingGoalPromptView: View {
    
    @Binding var onboardingStep: OnboardingView.OnboardingStep
    
    @Binding var whyCarnivore: WhyCarnivore?
    
    @State private var whyCarnivoreString: String = ""
    @FocusState private var isFocused
    
    var body: some View {
        VStack {
            HStack {
                Text("What is your goal with the carnivore diet?")
                    .font(.largeTitle)
                    .foregroundColor(.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("Why are you carnivore?")
                    .font(.title)
                    .foregroundColor(.text.opacity(0.5))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            WhyCarnivoreField()
            Spacer()
            Button {
                isFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onboardingStep = onboardingStep.next
                }
            } label: {
                Text("Let's do this!")
                    .foregroundColor(Color.background)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                            .foregroundStyle(Color.accentColor.gradient)
                    }
            }
            .disabled(whyCarnivoreString.isEmpty)
            Button {
                isFocused = false
                whyCarnivore = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onboardingStep = onboardingStep.skip
                }
            } label: {
                Text("Skip")
                    .foregroundColor(Color.accentColor.opacity(0.7))
            }
        }
        .padding()
        .background(Color.background)
        .onChange(of: whyCarnivoreString, initial: true) { newValue in
            whyCarnivore = .init(newValue)
        }
    }
    
    @ViewBuilder private func WhyCarnivoreField() -> some View {
        VStack {
            TextField(
                "Allergies, Skin Conditions, Weight Loss, etc...",
                text: $whyCarnivoreString,
                prompt: Text("Allergies, Skin Conditions, Weight Loss, etc...").foregroundStyle(Color.text.opacity(0.3)),
                axis: .vertical
            )
            .textInputAutocapitalization(.sentences)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
            HStack {
                Spacer()
                Text("\(whyCarnivoreString.count)/\(WhyCarnivore.maxLength)")
                    .font(.caption2)
                    .foregroundStyle(whyCarnivoreString.count > WhyCarnivore.maxLength ? Color.accentColor : Color.text)
                    .opacity(whyCarnivoreString.count > WhyCarnivore.maxLength ? 1 : isFocused ? 0.5 : 0)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .stroke(Color.accentColor, style: .init(lineWidth: 2))
        }
    }
}

#Preview {
    OnboardingGoalPromptView(onboardingStep: .constant(.goalPrompt), whyCarnivore: .constant(.none))
}
