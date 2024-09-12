//
//  ProfileFormUsernameField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import SwiftUI

struct ProfileFormUsernameField: View {
    
    @Binding var username: Username?
    let userId: String

    @State private var usernameStr: String = ""
    @State private var isAvailable: Bool = false
    @State private var isCheckingAvailability: Bool = false
    
    private var isUsernameValidAndAvailable: Bool { username != nil && isAvailable }
    
    private func checkAvailability() {
        guard let username = username else { return }
        isAvailable = false
        isCheckingAvailability = true
        
        Task {
            do {
                guard let checker = iocContainer.resolve(UsernameAvailabilityChecker.self) else {
                    return
                }
                
                isAvailable = try await checker.isAvailable(username: username, forUser: userId)
            } catch {
                print("Failed to check username availability. \(error.localizedDescription)")
            }
            isCheckingAvailability = false
        }
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
            guard username?.value != newValue else { return }
            username = Username(newValue)
            
            checkAvailability()
        }
        .onChange(of: username) { _, newValue in
            guard let value = newValue else { return }
            guard usernameStr != value.value else { return }
            usernameStr = value.value
            
            checkAvailability()
        }
    }
    
    @ViewBuilder func UsernameErrorView() -> some View {
        if isUsernameValidAndAvailable {
            ValidAvailableUsernameIndicator()
        } else if isCheckingAvailability {
            CheckingAvailabiltyIndicator()
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
    
    @ViewBuilder func CheckingAvailabiltyIndicator() -> some View {
        FormFieldErrorView(
            icon: "questionmark.circle.fill",
            text: String(localized: "Checking..."),
            color: .text.opacity(0.8)
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
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(Username("json")) { username in
            ProfileFormUsernameField(username: username, userId: "userId")
        }
    }
}

#Preview("Nil Username") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(nil) { username in
            ProfileFormUsernameField(username: username, userId: "userId")
        }
    }
}
