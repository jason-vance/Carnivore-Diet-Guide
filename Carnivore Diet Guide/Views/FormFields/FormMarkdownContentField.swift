//
//  FormMarkdownContentField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/28/24.
//

import SwiftUI
import MarkdownUI

struct FormMarkdownContentField<ErrorContent: View>: View {
    
    @Binding var markdownContent: String
    @State var label: String
    @State var prompt: String
    var hasError: Bool
    @State var autoCapitalization: TextInputAutocapitalization = .sentences
    @State var keyboard: UIKeyboardType = .default
    var onCommit: (() -> ())? = nil
    var errorContent: () -> ErrorContent

    @State private var myMarkdownContent: String = ""
    @State private var showEntryDialog: Bool = false
    @FocusState private var isFocused: Bool
    @State private var showQuickLook: Bool = false

    @State private var showError: Bool = false
    @State private var showErrorContent: Bool = false
    
    private func cancel() {
        showEntryDialog = false
    }
    
    private func save() {
        markdownContent = myMarkdownContent
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
        .fullScreenCover(isPresented: $showEntryDialog) {
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
        Text(markdownContent.isEmpty ? prompt : markdownContent)
        .font(.subHeaderRegular)
        .foregroundStyle(markdownContent.isEmpty ? Color.gray : Color.text)
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
                .padding(.horizontal)
                TextEditor(text: $myMarkdownContent)
                    .font(.subHeaderRegular)
                    .foregroundStyle(Color.text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autoCapitalization)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.leading)
                    .scrollContentBackground(.hidden)
                    .overlay(alignment: .topLeading) {
                        if myMarkdownContent.isEmpty {
                            Text(prompt)
                                .font(.subHeaderRegular)
                                .foregroundStyle(Color.gray)
                                .padding(.paddingMedium)
                        }
                    }
                    .overlay {
                        if showQuickLook {
                            QuickLookView()
                        }
                    }
                    .padding(.paddingMedium)
                    .background {
                        FormFieldOverlay {
                            isFocused = true
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        myMarkdownContent = markdownContent
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isFocused = true
                        }
                    }
                TextEditorControls()
            }
            .presentationBackground(Color.background)
        }
    }
    
    @ViewBuilder func TextEditorControls() -> some View {
        HStack {
            TitleMenu()
            ListMenu()
            BoldTextButton()
            ItalicizedTextButton()
            Spacer()
            QuickLookButton()
        }
        .padding(.horizontal)
        .padding(.vertical, .paddingMedium)
    }
    
    @ViewBuilder func QuickLookView() -> some View {
        ScrollView {
            Markdown(myMarkdownContent)
                .markdownTextStyle {
                    ForegroundColor(Color.text)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .background(Color.background)
    }
    
    @ViewBuilder func QuickLookButton() -> some View {
        Button {
            withAnimation(.snappy) {
                showQuickLook.toggle()
            }
        } label: {
            Image(systemName: "binoculars")
                .font(.subHeaderBold)
                .foregroundStyle(Color.accent)
                .overlay(alignment: .bottomTrailing) {
                    if showQuickLook {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.accent)
                            .padding(1)
                            .background{ Circle().fill(Color.background) }
                            .offset(x: 2, y: 2)
                    }
                }
        }
    }
    
    @ViewBuilder func TitleMenu() -> some View {
        Menu {
            TitleButton()
            HeaderButton()
            SubheaderButton()
        } label: {
            ControlButtonLabel("textformat.size")
        }
    }
    
    @ViewBuilder func TitleButton() -> some View {
        Button {
            myMarkdownContent += "# Title"
        } label: {
            Text("Title")
        }
    }
    
    @ViewBuilder func HeaderButton() -> some View {
        Button {
            myMarkdownContent += "## Header"
        } label: {
            Text("Header")
        }
    }
    
    @ViewBuilder func SubheaderButton() -> some View {
        Button {
            myMarkdownContent += "### Subheader"
        } label: {
            Text("Subheader")
        }
    }
    
    @ViewBuilder func ListMenu() -> some View {
        Menu {
            NumberedListButton()
            BulletedListButton()
        } label: {
            ControlButtonLabel("list.dash")
        }
    }
    
    @ViewBuilder func NumberedListButton() -> some View {
        Button {
            myMarkdownContent += "\n1. "
        } label: {
            Label("Numbered List", systemImage: "list.number")
        }
    }
    
    @ViewBuilder func BulletedListButton() -> some View {
        Button {
            myMarkdownContent += "\n- "
        } label: {
            Label("Bulleted List", systemImage: "list.bullet")
        }
    }
    
    @ViewBuilder func BoldTextButton() -> some View {
        Button {
            myMarkdownContent += "**Bold Text**"
        } label: {
            ControlButtonLabel("bold")
        }
    }
    
    @ViewBuilder func ItalicizedTextButton() -> some View {
        Button {
            myMarkdownContent += "*Italicized Text*"
        } label: {
            ControlButtonLabel("italic")
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            cancel()
        } label: {
            ControlButtonLabel("xmark")
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button {
            save()
        } label: {
            ControlButtonLabel("checkmark")
        }
    }
    
    @ViewBuilder func ControlButtonLabel(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.subHeaderBold)
            .foregroundStyle(Color.accent)
            .padding(.paddingMedium)
    }
}

#Preview {
    StatefulPreviewContainer("") { markdownContent in
        FormMarkdownContentField(
            markdownContent: markdownContent,
            label: "Label",
            prompt: "Prompt",
            hasError: markdownContent.wrappedValue.isEmpty) {
                Text(markdownContent.wrappedValue.isEmpty ? "Markdown Content must not be empty" : "")
            }
    }
}
