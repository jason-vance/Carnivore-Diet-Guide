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
            label: String(localized: "Name"),
            prompt: String(localized: "John Doe", comment: "Generic person's name"),
            hasError: !isNameValid,
            autoCapitalization: .words,
            errorContent: NameErrorView
        )
        .onChange(of: nameStr, perform: { value in
            guard name.wrappedValue?.value != value else { return }
            name.wrappedValue = try? PersonName(value)
        })
        .onChange(of: name.wrappedValue, perform: { value in
            guard let value = value else { return }
            guard nameStr != value.value else { return }
            nameStr = value.value
        })
    }
    
    @ViewBuilder func NameErrorView() -> some View {
        Text("Name must contain at least three letters")
    }
}

#Preview("Pre-filled Name") {
    StatefulPreviewContainer((try? PersonName("Jason Vance"))) { name in
        ProfileFormNameField(name)
    }
}

#Preview("Nil Name") {
    StatefulPreviewContainer(nil) { name in
        ProfileFormNameField(name)
    }
}
