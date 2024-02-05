//
//  ProfileFormUsernameField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ProfileFormUsernameField: View {
    
    enum UsernameAvailability {
        case undetermined
        case checking
        case available
        case unavailable
        case error
    }
    
    private let usernameChecker = iocContainer~>UsernameAvailabilityChecker.self
    
    private var username: Binding<Username?>
    
    @State private var usernameAvailability: UsernameAvailability = .undetermined
    @State private var usernameStr: String = ""
    private var isUsernameValid: Bool { username.wrappedValue != nil }
    
    init(_ username: Binding<Username?>) {
        self.username = username
    }
    
    private func checkUsernameAvailability() {
        guard let username = Username(usernameStr) else {
            usernameAvailability = .undetermined
            return
        }
        usernameAvailability = .checking
        
        Task {
            do {
                let available = try await usernameChecker.checkIsAvailable(username: username)
                usernameAvailability = available ? .available : .unavailable
            } catch {
                usernameAvailability = .error
            }
        }
    }
    
    private func onUpdate(usernameStr: String) {
        usernameAvailability = .undetermined
        username.wrappedValue = Username(usernameStr)
    }
    
    private func onUpdate(username: Username?) {
        guard let username = username else { return }
        
        // Make sure it is not already set to the new value
        // Otherwise changing `usernameStr` causes changes to `username` in an infinite loop
        guard usernameStr != username.value else { return }
        
        usernameStr = username.value
    }
    
    var body: some View {
        FormTextField(
            text: $usernameStr,
            prompt: "Username",
            onCommit: checkUsernameAvailability,
            errorView: {
                UsernameErrorView()
            }
        )
        .onAppear {
            usernameStr = username.wrappedValue?.value ?? ""
        }
        .onChange(of: usernameStr) { newUsernameStr in
            onUpdate(usernameStr: newUsernameStr)
        }
        .onChange(of: username.wrappedValue) { newUsername in
            onUpdate(username: newUsername)
        }
    }
    
    @ViewBuilder func UsernameErrorView() -> some View {
        if !isUsernameValid {
            InvalidUsernameIndicator()
        } else {
            switch usernameAvailability {
            case .undetermined:
                FormFieldErrorView.none
            case .checking:
                CheckingUsernameIndicator()
            case .available:
                UsernameIsAvailableIndicator()
            case .unavailable:
                UsernameAlreadyInUseIndicator()
            case .error:
                ErrorCheckingUsernameIndicator()
            }
        }
    }
    
    @ViewBuilder func InvalidUsernameIndicator() -> some View {
        FormFieldErrorView(
            icon: "exclamationmark.octagon.fill",
            text: "Username is invalid",
            color: .red
        )
    }
    
    @ViewBuilder func CheckingUsernameIndicator() -> some View {
        FormFieldErrorView(
            icon: "hourglass.circle.fill",
            text: "Checking...",
            color: .gray
        )
    }
    
    @ViewBuilder func UsernameIsAvailableIndicator() -> some View {
        FormFieldErrorView(
            icon: "checkmark.circle.fill",
            text: "Username is available",
            color: .green
        )
    }
    
    @ViewBuilder func UsernameAlreadyInUseIndicator() -> some View {
        FormFieldErrorView(
            icon: "exclamationmark.octagon.fill",
            text: "Username is already in use",
            color: .red
        )
    }
    
    @ViewBuilder func ErrorCheckingUsernameIndicator() -> some View {
        FormFieldErrorView(
            icon: "arrow.clockwise.circle.fill",
            text: "Check failed, tap to retry",
            color: .blue
        )
        .onTapGesture {
            checkUsernameAvailability()
        }
    }
}

#Preview("Pre-filled Username") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(Username("jasonvance77")) { username in
            ProfileFormUsernameField(username)
        }
    }
}

#Preview("Nil Username") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(nil) { username in
            ProfileFormUsernameField(username)
        }
    }
}
