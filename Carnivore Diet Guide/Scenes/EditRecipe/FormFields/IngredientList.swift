//
//  IngredientList.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct IngredientList: View {
    
    @Binding var ingredients: [Recipe.Ingredient]
    
    @State var showAddIngredientSheet: Bool = false
    
    var body: some View {
        VStack {
            IngredientsText()
            List($ingredients, editActions: [.move]) { $ingredient in
                IngredientItem(ingredient)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.background)
            }
            .listStyle(.plain)
            AddIngredientField()
        }
        .foregroundStyle(Color.text)
        .background(Color.background)
    }
    
    @ViewBuilder func IngredientsText() -> some View {
        HStack {
            Text("Ingredients")
                .font(.headerSemibold)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func IngredientItem(_ ingredient: Recipe.Ingredient) -> some View {
        HStack {
            HStack(alignment: .bottom, spacing: 4) {
                if ingredient.amount != nil || ingredient.unit != nil {
                    HStack(alignment: .bottom, spacing: 0) {
                        if let amount = ingredient.amountString {
                            Text(amount)
                                .font(.subHeaderRegular)
                        }
                        if let unit = ingredient.unit {
                            Text(unit.displayString)
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Text("x")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                Text(ingredient.name)
                    .font(.subHeaderRegular)
                if let notes = ingredient.notes {
                    Text("(\(notes))")
                        .font(.subHeaderRegular)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder func AddIngredientField() -> some View {
        Text("Add Ingredient")
    }
}

#Preview {
    StatefulPreviewContainer(Recipe.Ingredient.samples) { ingredients in
        IngredientList(ingredients: ingredients)
    }
}
