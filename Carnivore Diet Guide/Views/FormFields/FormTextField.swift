//
//  FormTextField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct FormTextField<ErrorContent: View>: View {
    
    @Binding var text: String
    @State var prompt: String
    @State var autoCapitalization: TextInputAutocapitalization = .never
    @State var keyboard: UIKeyboardType = .alphabet
    var onCommit: (() -> ())? = nil
    var errorView: () -> ErrorContent
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(prompt)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.text)
                Spacer()
            }
            .padding(.horizontal)
            TextField("", text: $text, onEditingChanged: { focused in
                if !focused {
                    onCommit?()
                }
            })
            .foregroundStyle(Color.text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(autoCapitalization)
            .autocorrectionDisabled()
            .focused($isFocused)
            .submitLabel(.done)
            .onSubmit(of: .text) {
                isFocused = false
            }
            .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
            .padding(.horizontal)
            .overlay {
                FormFieldOverlay {
                    isFocused = true
                }
            }
            errorView()
        }
    }
}

#Preview {
    StatefulPreviewContainer("") { text in
        FormTextField(
            text: text,
            prompt: "Text",
            errorView: {
                Text(String("Error"))
            }
        )
    }
}
