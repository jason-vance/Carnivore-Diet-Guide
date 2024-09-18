//
//  BasicNutritionInfoCreatorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import SwiftUI

struct BasicNutritionInfoCreatorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var nutritionInfo: BasicNutritionInfo?
    
    @State private var caloriesString: String = ""
    @State private var carbohydratesString: String = ""
    @State private var fatString: String = ""
    @State private var proteinString: String = ""
    
    private func populateFields() {
        guard let nutritionInfo = nutritionInfo else { return }
        
        caloriesString = "\(nutritionInfo.calories)"
        carbohydratesString = "\(nutritionInfo.carbohydrates)"
        fatString = "\(nutritionInfo.fat)"
        proteinString = "\(nutritionInfo.protein)"
    }

    private var formNutritionInfo: BasicNutritionInfo? {
        guard let calories = UInt(caloriesString) else { return nil }
        guard let protein = UInt(proteinString) else { return nil }
        guard let fat = UInt(fatString) else { return nil }
        guard let carbohydrates = UInt(carbohydratesString) else { return nil }

        return .init(
            calories: calories,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            List {
                CaloriesField()
                CarbohydratesField()
                FatField()
                ProteinField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .onAppear { populateFields() }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Nutrition Info") },
            leadingContent: CancelButton,
            trailingContent: DeleteAndSaveButtons
        )
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func DeleteAndSaveButtons() -> some View {
        HStack {
            if nutritionInfo != nil {
                DeleteButton()
            }
            SaveButton()
        }
    }
    
    @ViewBuilder func DeleteButton() -> some View {
        Button {
            self.nutritionInfo = nil
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "trash")
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        NextButton {
            guard let nutritionInfo = formNutritionInfo else { return }
            self.nutritionInfo = nutritionInfo
            dismiss()
        }
        .disabled(formNutritionInfo == nil)
    }
    
    @ViewBuilder func CaloriesField() -> some View {
        Section {
            TextField("Calories", text: $caloriesString, prompt: Text("Calories"))
                .keyboardType(.numberPad)
                .padding(.horizontal, .paddingHorizontalButtonMedium)
                .padding(.vertical, .paddingVerticalButtonMedium)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
                        .foregroundStyle(Color.accent)
                }
                .frame(width: 120)
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
        } header: {
            Text("Calories")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func CarbohydratesField() -> some View {
        Section {
            TextField("Carbohydrates", text: $carbohydratesString, prompt: Text("Carbohydrates"))
                .keyboardType(.numberPad)
                .padding(.horizontal, .paddingHorizontalButtonMedium)
                .padding(.vertical, .paddingVerticalButtonMedium)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
                        .foregroundStyle(Color.accent)
                }
                .frame(width: 120)
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
        } header: {
            Text("Carbohydrates")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func FatField() -> some View {
        Section {
            TextField("Fat", text: $fatString, prompt: Text("Fat"))
                .keyboardType(.numberPad)
                .padding(.horizontal, .paddingHorizontalButtonMedium)
                .padding(.vertical, .paddingVerticalButtonMedium)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
                        .foregroundStyle(Color.accent)
                }
                .frame(width: 120)
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
        } header: {
            Text("Fat")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func ProteinField() -> some View {
        Section {
            TextField("Protein", text: $proteinString, prompt: Text("Protein"))
                .keyboardType(.numberPad)
                .padding(.horizontal, .paddingHorizontalButtonMedium)
                .padding(.vertical, .paddingVerticalButtonMedium)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
                        .foregroundStyle(Color.accent)
                }
                .frame(width: 120)
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
        } header: {
            Text("Protein")
                .foregroundStyle(Color.text)
        }
    }
}

#Preview {
    BasicNutritionInfoCreatorView(nutritionInfo: .constant(.sample))
}
