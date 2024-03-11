//
//  BasicNutritionInfoEntryDialog.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/11/24.
//

import SwiftUI

struct BasicNutritionInfoEntryDialog: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var nutritionInfo: BasicNutritionInfo
    @State private var myNutritionInfo: BasicNutritionInfo = .zero
    
    @State private var isCaloriesDialogPresented: Bool = false
    @State private var isProteinDialogPresented: Bool = false
    @State private var isFatDialogPresented: Bool = false
    @State private var isCarbsDialogPresented: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TitleBar(text: String(localized: "Nutrition Info"))
            ScrollView {
                VStack {
                    CaloriesField()
                    ProteinField()
                    FatField()
                    CarbsField()
                }
                .padding(.paddingDefault)
            }
            .overlay(alignment: .top) {
                ScrollViewShroud()
            }
            Spacer()
            DialogControlButtons()
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.background)
        .onAppear {
            myNutritionInfo = nutritionInfo
        }
    }
    
    @ViewBuilder func CaloriesField() -> some View {
        FormDialogField(
            label: String(localized: "Calories"),
            isDialogPresented: $isCaloriesDialogPresented,
            hasError: false) {
                Text("\(myNutritionInfo.calories.formatted())")
            } errorContent: {
                Text("Calories must be greater than 0")
            }
            .sheet(isPresented: $isCaloriesDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Calories"),
                    number: .init(
                        get: { myNutritionInfo.calories },
                        set: { myNutritionInfo.calories = $0 ?? myNutritionInfo.calories }
                    )
                )
            }
    }
    
    @ViewBuilder func ProteinField() -> some View {
        FormDialogField(
            label: String(localized: "Protein"),
            isDialogPresented: $isProteinDialogPresented,
            hasError: false) {
                Text("\(myNutritionInfo.protein.formatted())")
            } errorContent: {
                Text("Protein must be greater than 0")
            }
            .sheet(isPresented: $isProteinDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Protein"),
                    number: .init(
                        get: { myNutritionInfo.protein },
                        set: { myNutritionInfo.protein = $0 ?? myNutritionInfo.protein }
                    )
                )
            }
    }
    
    @ViewBuilder func FatField() -> some View {
        FormDialogField(
            label: String(localized: "Fat"),
            isDialogPresented: $isFatDialogPresented,
            hasError: false) {
                Text("\(myNutritionInfo.fat.formatted())")
            } errorContent: {
                Text("Fat must be greater than 0")
            }
            .sheet(isPresented: $isFatDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Fat"),
                    number: .init(
                        get: { myNutritionInfo.fat },
                        set: { myNutritionInfo.fat = $0 ?? myNutritionInfo.fat }
                    )
                )
            }
    }
    
    @ViewBuilder func CarbsField() -> some View {
        FormDialogField(
            label: String(localized: "Carbohydrate"),
            isDialogPresented: $isCarbsDialogPresented,
            hasError: false) {
                Text("\(myNutritionInfo.carbohydrates.formatted())")
            } errorContent: {
                Text("Carbohydrate must be greater than 0")
            }
            .sheet(isPresented: $isCarbsDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Carbohydrate"),
                    number: .init(
                        get: { myNutritionInfo.carbohydrates },
                        set: { myNutritionInfo.carbohydrates = $0 ?? myNutritionInfo.carbohydrates }
                    )
                )
            }
    }
    
    @ViewBuilder func DialogControlButtons() -> some View {
        HStack {
            ClearButton()
            SaveButton()
        }
        .padding(.paddingDefault)
    }
    
    @ViewBuilder func ClearButton() -> some View {
        Button {
            withAnimation(.snappy) {
                myNutritionInfo = .zero
            }
        } label: {
            Text("Clear")
                .font(.subHeaderBold)
                .foregroundStyle(Color.accent)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                        .stroke(lineWidth: .buttonStrokeWidthDefault)
                        .foregroundStyle(Color.accentColor)
                }
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button {
            nutritionInfo = myNutritionInfo
            dismiss()
        } label: {
            Text("OK")
                .font(.subHeaderBold)
                .foregroundStyle(Color.background)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                        .foregroundStyle(Color.accentColor)
                }
        }
    }
}

#Preview {
    StatefulPreviewContainer(true) { isShown in
        StatefulPreviewContainer(BasicNutritionInfo.zero) { info in
            Button {
                isShown.wrappedValue = true
            } label: {
                VStack {
                    Text("Calories: \(info.wrappedValue.calories)")
                    Text("Protein: \(info.wrappedValue.protein)")
                    Text("Fat: \(info.wrappedValue.fat)")
                    Text("Carbs: \(info.wrappedValue.carbohydrates)")
                }
            }
            .sheet(isPresented: isShown) {
                BasicNutritionInfoEntryDialog(nutritionInfo: info)
            }
        }
    }
}
