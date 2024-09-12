//
//  ProfileFormUsernameField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import SwiftUI

struct ProfileFormUsernameField: View {
    
    private var username: Binding<Username?>
    private var isUsernameValid: Bool { username.wrappedValue != nil }

    @State private var usernameStr: String
    
    init(_ username: Binding<Username?>) {
        self.username = username
        self.usernameStr = username.wrappedValue?.value ?? ""
    }
    
    var body: some View {
        FormTextField(
            text: $usernameStr,
            prompt: String(localized: "Username"),
            autoCapitalization: .never,
            errorView: {
                UsernameErrorView()
            }
        )
        .onChange(of: usernameStr) { _, newValue in
            guard username.wrappedValue?.value != newValue else { return }
            username.wrappedValue = Username(newValue)
        }
        .onChange(of: username.wrappedValue) { _, newValue in
            guard let value = newValue else { return }
            guard usernameStr != value.value else { return }
            usernameStr = value.value
            
            //TODO: Check availability
        }
    }
    
    @ViewBuilder func UsernameErrorView() -> some View {
        if isUsernameValid {
            ValidAvailableUsernameIndicator()
        } else {
            InvalidUsernameIndicator()
        }
    }
    
    @ViewBuilder func ValidAvailableUsernameIndicator() -> some View {
        FormFieldErrorView(
            icon: "checkmark.circle.fill",
            text: String(localized: "Username is valid and available"),
            color: .green
        )
    }
    
    @ViewBuilder func InvalidUsernameIndicator() -> some View {
        FormFieldErrorView(
            icon: "exclamationmark.octagon.fill",
            text: String(localized: "3-32 characters. No spaces. At least 1 letter."),
            color: .red
        )
    }
}

#Preview("Pre-filled Username") {
    StatefulPreviewContainer(Username("json")) { username in
        ProfileFormUsernameField(username)
    }
}

#Preview("Nil Username") {
    StatefulPreviewContainer(nil) { username in
        ProfileFormUsernameField(username)
    }
}
