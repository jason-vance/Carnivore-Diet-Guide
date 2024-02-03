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
            prompt: "Name",
            autoCapitalization: .words,
            errorView: {
                NameErrorView()
            }
        )
        .onChange(of: nameStr, perform: { value in
            guard name.wrappedValue?.value != value else { return }
            name.wrappedValue = PersonName(value)
        })
        .onChange(of: name.wrappedValue, perform: { value in
            guard let value = value else { return }
            guard nameStr != value.value else { return }
            nameStr = value.value
        })
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
            text: "Name must contain at least three letters",
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
