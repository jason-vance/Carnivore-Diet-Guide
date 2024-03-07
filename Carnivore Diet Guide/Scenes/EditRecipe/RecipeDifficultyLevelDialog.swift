//
//  RecipeDifficultyLevelDialog.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/6/24.
//

import SwiftUI

struct RecipeDifficultyLevelDialog: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var difficultyLevel: Recipe.DifficultyLevel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar(text: String(localized: "Difficulty Level"))
            ScrollView {
                VStack(spacing: .paddingMedium) {
                    DifficultyLevelOption(.easy)
                    DifficultyLevelOption(.intermediate)
                    DifficultyLevelOption(.hard)
                }
                .padding()
            }
        }
        .presentationBackground(Color.background)
        .presentationDetents([.medium])
    }
    
    @ViewBuilder func DifficultyLevelOption(_ level: Recipe.DifficultyLevel) -> some View {
        Button {
            difficultyLevel = level
            dismiss()
        } label: {
            VStack(spacing: .paddingMedium) {
                Text(level.uiString)
                    .font(.subHeaderBold)
                Text(level.explanation)
                    .font(.bodyText)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.paddingDefault)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                    .stroke(lineWidth: .buttonStrokeWidthDefault)
                    .foregroundStyle(Color.accent)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: level == difficultyLevel ? "checkmark.circle.fill" : "circle")
                    .padding(.paddingDefault)
            }
        }
    }
}

#Preview {
    StatefulPreviewContainer(Recipe.DifficultyLevel.easy) { difficultyLevel in
        StatefulPreviewContainer(true) { isShown in
            Rectangle()
                .sheet(isPresented: isShown) {
                    RecipeDifficultyLevelDialog(difficultyLevel: difficultyLevel)
                }
        }
    }
}
