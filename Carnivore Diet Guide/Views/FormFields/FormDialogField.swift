//
//  FormDialogField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/26/24.
//

import SwiftUI

struct FormDialogField<ValueContent: View, ErrorContent: View>: View {
    
    @State var label: String
    @Binding var isDialogPresented: Bool
    var hasError: Bool
    @State private var showError: Bool = false
    @State private var showErrorContent: Bool = false

    var valueContent: () -> ValueContent
    var errorContent: () -> ErrorContent

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
            Button {
                showErrorContent = false
                isDialogPresented = true
            } label: {
                VStack(spacing: 2) {
                    HStack {
                        LabelText()
                        Spacer()
                        TextFieldView()
                    }
                    .padding(.horizontal)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                            .stroke(lineWidth: .buttonStrokeWidthDefault)
                            .foregroundStyle(Color.accentColor)
                    }
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
        valueContent()
            .padding(.horizontal, .paddingDefault)
            .padding(.vertical, .paddingMedium)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                    .fill(Color.accent.opacity(0.2))
            }
            .frame(height: 48)
    }
}

#Preview {
    StatefulPreviewContainer(false) { isDialogPresented in
        FormDialogField(
            label: "Label",
            isDialogPresented: isDialogPresented,
            hasError: isDialogPresented.wrappedValue) {
                Text("--")
            } errorContent: {
                Text("Text must not be empty")
            }
    }
}
