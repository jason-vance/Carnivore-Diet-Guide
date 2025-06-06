//
//  ProfileFormNameField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct ProfileFormNameField: View {
    
    private var name: Binding<PersonName?>
    private var isNameValid: Bool { name.wrappedValue != nil }

    @State private var nameStr: String
    
    init(_ name: Binding<PersonName?>) {
        self.name = name
        self.nameStr = name.wrappedValue?.value ?? ""
    }
    
    var body: some View {
        FormTextField(
            text: $nameStr,
            prompt: String(localized: "Name"),
            autoCapitalization: .words,
            errorView: {
                NameErrorView()
            }
        )
        .onChange(of: nameStr) { _, newValue in
            guard name.wrappedValue?.value != newValue else { return }
            name.wrappedValue = PersonName(newValue)
        }
        .onChange(of: name.wrappedValue) { _, newValue in
            guard let value = newValue else { return }
            guard nameStr != value.value else { return }
            nameStr = value.value
        }
    }
    
    @ViewBuilder func NameErrorView() -> some View {
        if isNameValid {
            FormFieldErrorView.none
        } else {
            InvalidNameIndicator()
        }
    }
    
    @ViewBuilder func InvalidNameIndicator() -> some View {
        FormFieldErrorView(
            icon: "exclamationmark.octagon.fill",
            text: String(localized: "Name must contain at least three letters"),
            color: .red
        )
    }
}

#Preview("Pre-filled Name") {
    StatefulPreviewContainer(PersonName("Jason Vance")) { name in
        ProfileFormNameField(name)
    }
}

#Preview("Nil Name") {
    StatefulPreviewContainer(nil) { name in
        ProfileFormNameField(name)
    }
}
