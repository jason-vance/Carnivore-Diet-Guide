//
//  FormTextField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct FormTextField<ErrorContent: View>: View {
    
    @Binding var text: String
    @State var label: String
    @State var prompt: String
    var hasError: Bool
    @State var clearable: Bool = false
    @State var autoCapitalization: TextInputAutocapitalization = .never
    @State var keyboard: UIKeyboardType = .alphabet
    var onCommit: (() -> ())? = nil
    var errorContent: () -> ErrorContent

    @FocusState var isFocused: Bool
    
    @State private var showError: Bool = false
    @State private var showErrorContent: Bool = false
    
    var body: some View {
        HStack {
            if showError {
                Button {
                    showErrorContent = true
                } label: {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.subHeaderBold)
                        .foregroundStyle(Color.accent)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .leading),
                    removal: .push(from: .trailing)
                ))
                .popover(isPresented: $showErrorContent) {
                    errorContent()
                        .padding(.horizontal)
                        .presentationCompactAdaptation(.popover)
                }
            }
            HStack {
                LabelText()
                TextFieldView()
                if clearable {
                    ClearButton()
                }
            }
            .padding(.horizontal)
            .background {
                FormFieldOverlay {
                    isFocused = true
                }
            }
        }
        .onChange(of: hasError, initial: true) { newHasError in
            withAnimation(.snappy) {
                showError = newHasError
            }
        }
    }
    
    @ViewBuilder func LabelText() -> some View {
        Text(label)
            .font(.subHeaderBold)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func TextFieldView() -> some View {
        TextField(prompt, text: $text, onEditingChanged: { focused in
            if !focused {
                onCommit?()
            }
        })
        .font(.subHeaderRegular)
        .foregroundStyle(Color.text)
        .keyboardType(keyboard)
        .textInputAutocapitalization(autoCapitalization)
        .autocorrectionDisabled()
        .focused($isFocused)
        .submitLabel(.done)
        .onSubmit(of: .text) {
            isFocused = false
        }
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
        .multilineTextAlignment(.trailing)
    }
    
    @ViewBuilder func ClearButton() -> some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.subHeaderRegular)
                .foregroundStyle(Color.accent)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    StatefulPreviewContainer("") { text in
        FormTextField(
            text: text,
            label: "Label",
            prompt: "Prompt",
            hasError: text.wrappedValue.isEmpty) {
                Text(text.wrappedValue.isEmpty ? "Text must not be empty" : "")
            }
    }
}

#Preview("Clearable") {
    StatefulPreviewContainer("") { text in
        FormTextField(
            text: text,
            label: "Label",
            prompt: "Prompt",
            hasError: text.wrappedValue.isEmpty,
            clearable: true) {
                Text(text.wrappedValue.isEmpty ? "Text must not be empty" : "")
            }
    }
}
