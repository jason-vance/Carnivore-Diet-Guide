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
    @State var clearable: Bool = false
    @State var autoCapitalization: TextInputAutocapitalization = .never
    @State var keyboard: UIKeyboardType = .alphabet
    var onCommit: (() -> ())? = nil
    var errorView: () -> ErrorContent
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 2) {
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
            errorView()
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
            prompt: "Prompt") {
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
            clearable: true) {
                Text(text.wrappedValue.isEmpty ? "Text must not be empty" : "")
            }
    }
}
