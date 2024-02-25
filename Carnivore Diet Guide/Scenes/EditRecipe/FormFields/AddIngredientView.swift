//
//  AddIngredientView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct AddIngredientView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @Binding var ingredient: Recipe.Ingredient?
    
    @State private var amount: Int?
    @State private var unit: Recipe.Ingredient.Unit?
    @State private var name: String?
    @State private var notes: String?
    
    @State private var showAmountEntryDialog: Bool = false
    @State private var showUnitEntryDialog: Bool = false
    @State private var showNameEntryDialog: Bool = false
    @State private var showNotesEntryDialog: Bool = false
    
    func presentationHeight(_ proxy: GeometryProxy) -> CGFloat {
        (5 * CGFloat.titleBarHeight) + (4 * CGFloat.paddingDefault) + proxy.safeAreaInsets.bottom
    }

    private func saveIngredient() {
        
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .paddingDefault) {
                TitleBar(text: ingredient == nil ? "Add Ingredient" : "Edit Ingredient")
                    .overlay(alignment: .trailing) {
                        SaveButton()
                            .padding()
                    }
                AmountField()
                UnitField()
                NameField()
                NotesField()
                Spacer()
            }
            .presentationDetents([.height(presentationHeight(proxy))])
            .interactiveDismissDisabled()
            .presentationBackground(Color.background)
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button {
            saveIngredient()
        } label: {
            Image(systemName: "checkmark")
                .bold()
        }
    }
    
    @ViewBuilder func AmountField() -> some View {
        Button {
            showAmountEntryDialog = true
        } label: {
            FieldButtonLabel(
                "Amount",
                value: "\(amount?.formatted() ?? "--")"
            )
        }
        .sheet(isPresented: $showAmountEntryDialog) {
            NumberEntryDialogView(prompt: "Enter the amount", number: $amount)
        }
    }
    
    @ViewBuilder func UnitField() -> some View {
        Button {
            showUnitEntryDialog = true
        } label: {
            FieldButtonLabel(
                "Unit",
                value: unit?.displayString ?? "--"
            )
        }
        .sheet(isPresented: $showUnitEntryDialog) {
            IngredientUnitDialog(prompt: "Enter the unit", unit: $unit)
        }
    }
    
    @ViewBuilder func NameField() -> some View {
        Button {
            showNameEntryDialog = true
        } label: {
            FieldButtonLabel(
                "Name",
                value: name ?? "--"
            )
        }
    }
    
    @ViewBuilder func NotesField() -> some View {
        Button {
            showNotesEntryDialog = true
        } label: {
            FieldButtonLabel(
                "Notes",
                value: notes ?? "--"
            )
        }
    }
    
    @ViewBuilder func FieldButtonLabel(_ labelText: String, value: String) -> some View {
        HStack {
            Text(labelText)
                .font(.subHeaderBold)
                .foregroundStyle(Color.text)
            Spacer()
            Text(value)
                .font(.subHeaderBold)
                .padding(.horizontal, .paddingDefault)
                .padding(.vertical, .paddingMedium)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                        .opacity(0.2)
                }
        }
        .padding(.vertical, .paddingMedium)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                .stroke(lineWidth: .buttonStrokeWidthDefault)
                .foregroundStyle(Color.accent)
                .frame(height: .titleBarHeight)
        }
        .padding(.horizontal)
    }
}

#Preview {
    StatefulPreviewContainer(nil) { ingredient in
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                AddIngredientView(ingredient: ingredient)
            }
    }
}
