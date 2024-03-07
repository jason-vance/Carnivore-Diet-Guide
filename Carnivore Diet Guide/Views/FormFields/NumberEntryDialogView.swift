//
//  NumberEntryDialogView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct NumberEntryDialogView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var prompt: String
    @Binding var number: Int?

    @State private var numberString: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private func prepopulateIfNecessary() {
        if let number = number {
            numberString = String(number)
        }
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private var numberStringAsNumber: Int? {
        Int(numberString)
    }
    
    private func saveNumber() {
        number = numberStringAsNumber
        dismiss()
    }
    
    var body: some View {
        VStack {
            TitleBar(text: prompt)
                .overlay(alignment: .trailing) {
                    SaveButton()
                }
            Spacer()
            NumberDisplay()
            Spacer()
            KeyPad()
        }
        .background(Color.background)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
        .alert(alertMessage, isPresented: $showAlert) {}
        .onAppear { prepopulateIfNecessary() }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button{
            saveNumber()
        } label: {
            Image(systemName: "checkmark")
                .bold()
                .foregroundStyle(Color.accent)
                .padding()
        }
    }
    
    @ViewBuilder func NumberDisplay() -> some View {
        Text("\(numberStringAsNumber?.formatted() ?? "--")")
                .font(.titleBold)
                .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func KeyPad() -> some View {
        VStack {
            HStack {
                ForEach(1...3, id: \.self) { number in
                    NumberButton(number)
                }
            }
            HStack {
                ForEach(4...6, id: \.self) { number in
                    NumberButton(number)
                }
            }
            HStack {
                ForEach(7...9, id: \.self) { number in
                    NumberButton(number)
                }
            }
            HStack {
                PeriodButton().opacity(0)
                NumberButton(0)
                DeleteButton()
            }
        }
        .padding()
    }
    
    @ViewBuilder func NumberButton(_ number: Int) -> some View {
        Button {
            numberString.append("\(number)")
        } label: {
            Text("\(number)")
                .font(.subHeaderBold)
                .foregroundStyle(Color.text)
                .padding()
                .frame(maxWidth: .infinity)
                .background { ButtonBackground() }
        }
    }
    
    @ViewBuilder func PeriodButton() -> some View {
        Button {
            numberString.append(".")
        } label: {
            Text(".")
                .font(.subHeaderBold)
                .foregroundStyle(Color.text)
                .padding()
                .frame(maxWidth: .infinity)
                .background { ButtonBackground() }
        }
    }
    
    @ViewBuilder func DeleteButton() -> some View {
        Button {
            guard !numberString.isEmpty else { return }
            numberString.removeLast()
        } label: {
            Image(systemName: "delete.backward")
                .font(.titleRegular)
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder func ButtonBackground() -> some View {
        RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
            .stroke(lineWidth: .buttonStrokeWidthDefault)
            .foregroundStyle(Color.accent)
    }
}

#Preview {
    StatefulPreviewContainer(0 as Int?) { number in
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                NumberEntryDialogView(prompt: "Enter Your Number", number: number)
            }
    }
}
