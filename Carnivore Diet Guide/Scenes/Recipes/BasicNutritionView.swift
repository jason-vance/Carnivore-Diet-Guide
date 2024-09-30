//
//  BasicNutritionView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/30/24.
//

import SwiftUI

struct BasicNutritionView: View {
    
    @State var nutritionInfo: BasicNutritionInfo
    
    var body: some View {
        VStack {
            CaloriesLine()
            DividerLine()
            ProteinLine()
            FatLine()
            CarbsLine()
        }
        .foregroundStyle(Color.text)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .stroke(style: .init(lineWidth: .borderWidthThin))
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func DividerLine() -> some View {
        Rectangle()
            .frame(width: .infinity, height: 0.5)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func CaloriesLine() -> some View {
        NutrientInfoLine(
            "Calories",
            amount: nutritionInfo.calories,
            unit: "cals"
        )
    }
    
    @ViewBuilder func ProteinLine() -> some View {
        MacroNutrientLine(
            String(localized: "Protein"),
            amount: nutritionInfo.protein
        )
    }
    
    @ViewBuilder func FatLine() -> some View {
        MacroNutrientLine(
            String(localized: "Fat"),
            amount: nutritionInfo.fat
        )
    }
    
    @ViewBuilder func CarbsLine() -> some View {
        MacroNutrientLine(
            String(localized: "Carbohydrate"),
            amount: nutritionInfo.carbohydrates
        )
    }
    
    @ViewBuilder func MacroNutrientLine(_ text: String, amount: UInt) -> some View {
        NutrientInfoLine(
            text,
            amount: amount,
            unit: "g"
        )
    }
    
    @ViewBuilder func NutrientInfoLine(_ text: String, amount: UInt, unit: String) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .font(.headline.weight(.semibold))
            Spacer(minLength: 0)
            Text("\(amount)")
                .font(.headline.weight(.bold))
            Text(unit)
                .font(.body.weight(.regular))
        }
    }
}

#Preview {
    BasicNutritionView(nutritionInfo: .sample)
}
