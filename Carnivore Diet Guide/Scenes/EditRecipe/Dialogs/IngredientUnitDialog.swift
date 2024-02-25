//
//  IngredientUnitDialog.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import SwiftUI

struct IngredientUnitDialog: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var prompt: String
    @Binding var unit: Recipe.Ingredient.Unit?

    @State private var unitString: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var unitStringAsUnit: Recipe.Ingredient.Unit? {
        return .init(name: unitString)
    }
    
    private func prepopulateIfNecessary() {
        if let unit = unit {
            unitString = unit.displayString
        }
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private func saveUnit() {
        unit = unitStringAsUnit
        dismiss()
    }
    
    var body: some View {
        VStack {
            TitleBar(text: prompt)
                .overlay(alignment: .trailing) {
                    SaveButton()
                }
            VStack(spacing: 0) {
                UnitTextField()
                UnitCloud()
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.background)
        .interactiveDismissDisabled()
        .alert(alertMessage, isPresented: $showAlert) {}
        .onAppear { prepopulateIfNecessary() }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button{
            saveUnit()
        } label: {
            Image(systemName: "checkmark")
                .bold()
                .foregroundStyle(Color.accent)
                .padding()
        }
    }
    
    @ViewBuilder func UnitTextField() -> some View {
        FormTextField(
            text: $unitString,
            label: String(localized: "Unit", comment: "Unit of measurement"),
            prompt: String(localized: "tsp, cup, etc."),
            clearable: true
        ) {
            Group {}
        }
        .padding()
    }
    
    @ViewBuilder func UnitCloud() -> some View {
        let items = Recipe.Ingredient.Unit.all
            .sorted{ $0.displayString.localizedCompare($1.displayString) == .orderedAscending }
        
        ScrollView {
            FlowLayout(
                mode: .scrollable,
                items: .constant(items)
            ) { item in
                Button {
                    unitString = item.displayString
                    saveUnit()
                } label: {
                    Text(item.displayString)
                        .font(.subHeaderBold)
                        .foregroundStyle(Color.text)
                        .padding()
                        .background {
                            RoundedRectangle(
                                cornerRadius: .cornerRadiusDefault,
                                style: .continuous
                            )
                            .stroke(lineWidth: .buttonStrokeWidthDefault)
                            .foregroundStyle(Color.accent)
                        }
                }
            }
            .padding()
        }
        .overlay(alignment: .top) {
            ScrollViewShroud()
        }
    }
    
    @ViewBuilder func ClearButton() -> some View {
        Button {
            unitString = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.accent)
                .padding()
        }
        .offset(y: 4)
    }
}

#Preview {
    StatefulPreviewContainer(true) { show in
        StatefulPreviewContainer(nil as Recipe.Ingredient.Unit?) { unit in
            Button {
                show.wrappedValue = true
            } label: {
                Text(unit.wrappedValue?.displayString ?? "<no unit>")
            }
            .sheet(isPresented: show) {
                IngredientUnitDialog(prompt: "Enter Your Unit", unit: unit)
            }
        }
    }
}
