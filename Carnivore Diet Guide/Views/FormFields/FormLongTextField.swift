//
//  FormLongTextField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/27/24.
//

import SwiftUI

struct FormLongTextField<ErrorContent: View>: View {
    
    @Binding var text: String
    @State var label: String
    @State var prompt: String
    var hasError: Bool
    @State var autoCapitalization: TextInputAutocapitalization = .sentences
    @State var keyboard: UIKeyboardType = .default
    var onCommit: (() -> ())? = nil
    var errorContent: () -> ErrorContent

    @State private var myText: String = ""
    @State private var showEntryDialog: Bool = false
    @FocusState private var isFocused: Bool

    @State private var showError: Bool = false
    @State private var showErrorContent: Bool = false
    
    private func cancel() {
        showEntryDialog = false
    }
    
    private func save() {
        text = myText
        showEntryDialog = false
    }
    
    var body: some View {
        HStack {
            if showError {
                ErrorButton()
            }
            HStack {
                LabelText()
                TextFieldView()
            }
            .padding(.horizontal)
            .background {
                FormFieldOverlay {
                    showEntryDialog = true
                }
            }
        }
        .onChange(of: hasError, initial: true) { newHasError in
            withAnimation(.snappy) {
                showError = newHasError
            }
        }
        .sheet(isPresented: $showEntryDialog) {
            EntryDialog()
        }
    }
    
    @ViewBuilder func ErrorButton() -> some View {
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
    
    @ViewBuilder func LabelText() -> some View {
        Text(label)
            .font(.subHeaderBold)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func TextFieldView() -> some View {
        Text(text.isEmpty ? prompt : text)
        .font(.subHeaderRegular)
        .foregroundStyle(text.isEmpty ? Color.gray : Color.text)
        .lineLimit(1)
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .trailing)
    }
    
    @ViewBuilder func EntryDialog() -> some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    CancelButton()
                    LabelText()
                    Spacer()
                    SaveButton()
                }
                .padding()
                TextEditor(text: $myText)
                    .font(.subHeaderRegular)
                    .foregroundStyle(Color.text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autoCapitalization)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.leading)
                    .scrollContentBackground(.hidden)
                    .overlay(alignment: .topLeading) {
                        if myText.isEmpty {
                            Text(prompt)
                                .font(.subHeaderRegular)
                                .foregroundStyle(Color.gray)
                                .padding(.paddingMedium)
                        }
                    }
                    .padding(.paddingMedium)
                    .background {
                        FormFieldOverlay {
                            isFocused = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .onAppear {
                        myText = text
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isFocused = true
                        }
                    }
            }
            .presentationDetents([.height(geo.size.width / 2)])
            .presentationBackground(Color.background)
            .interactiveDismissDisabled()
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            cancel()
        } label: {
            Image(systemName: "xmark")
                .font(.subHeaderBold)
                .foregroundStyle(Color.accent)
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button {
            save()
        } label: {
            Image(systemName: "checkmark")
                .font(.subHeaderBold)
                .foregroundStyle(Color.accent)
        }
    }
}

#Preview {
    StatefulPreviewContainer("") { text in
        FormLongTextField(
            text: text,
            label: "Label",
            prompt: "Prompt",
            hasError: text.wrappedValue.isEmpty) {
                Text(text.wrappedValue.isEmpty ? "Text must not be empty" : "")
            }
    }
}
