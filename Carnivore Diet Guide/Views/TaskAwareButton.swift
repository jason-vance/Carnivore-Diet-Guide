//
//  TaskAwareButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import SwiftUI

enum TaskStatus: Equatable {
    case idle
    case failed(String)
    case success
}

struct TaskAwareButton<Label: View>: View {
    
    var showErrorsAsAlert: Bool
    var buttonColor: Color
    var contentColor: Color
    var action: () async -> TaskStatus
    var label: () -> Label
    
    @State private var isLoading: Bool = false
    @State private var taskStatus: TaskStatus = .idle
    @State private var isFailed: Bool = false
    @State private var wiggle: Bool = false
    
    public init(
        buttonColor: Color = .accentColor,
        contentColor: Color = .white,
        showErrorsAsAlert: Bool = false,
        action: @escaping () async -> TaskStatus,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.buttonColor = buttonColor
        self.contentColor = contentColor
        self.showErrorsAsAlert = showErrorsAsAlert
        self.action = action
        self.label = label
    }
    
    @State private var showPopup: Bool = false
    @State private var popupMessage: String = ""
    
    var body: some View {
        Button {
            Task {
                isLoading = true
                taskStatus = await action()
                
                switch taskStatus {
                case .idle:
                    isFailed = false
                case .failed(let reason):
                    isFailed = true
                    popupMessage = reason
                case .success:
                    isFailed = false
                }
                
                wiggle = isFailed
                try? await Task.sleep(for: .seconds(0.8))
                showPopup = isFailed
                
                taskStatus = .idle
                isLoading = false
            }
        } label: {
            label()
                .padding()
                .foregroundColor(contentColor)
                .opacity(isLoading ? 0 : 1)
                .lineLimit(1)
                .frame(width: isLoading ? 48 : nil, height: 48)
                .background {
                    RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                        .fill(taskStatus == .idle
                              ? buttonColor
                              : taskStatus == .success
                              ? .green
                              : .red)
                }
                .clipped()  // So shadows only apply to capsule shape
                .overlay {
                    if isLoading && taskStatus == .idle {
                        ProgressView()
                            .tint(contentColor)
                    }
                }
                .overlay {
                    if taskStatus != .idle {
                        Image(systemName: isFailed ? "exclamationmark" : "checkmark")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
        }
        .disabled(isLoading)
        .errorPopover(
            isPresented: $showPopup,
            text: popupMessage,
            showAsAlert: showErrorsAsAlert
        )
        .animation(.snappy(), value: isLoading)
        .animation(.snappy(), value: taskStatus)
        .shake($wiggle)
    }
}

fileprivate extension View {
    @ViewBuilder func errorPopover(isPresented: Binding<Bool>, text: String, showAsAlert: Bool = false) -> some View {
        if showAsAlert {
            self.alert(text, isPresented: isPresented) {}
        } else {
            self.popover(isPresented: isPresented) {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}

#Preview {
    ZStack {
        VStack {
            TaskAwareButton() {
                try? await Task.sleep(for: .seconds(2))
                return .failed("Password Incorrect!")
            } label: {
                HStack(spacing: 10) {
                    Text("Failing")
                }
                .fontWeight(.bold)
            }
            
            TaskAwareButton() {
                try? await Task.sleep(for: .seconds(2))
                return .success
            } label: {
                HStack(spacing: 10) {
                    Text("Succeeding")
                    Image(systemName: "chevron.right")
                }
                .fontWeight(.bold)
            }
            
            TaskAwareButton() {
                try? await Task.sleep(for: .seconds(2))
                return .failed("failed")
            } label: {
                Text("Continue")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
        }
    }
    .preferredColorScheme(.light)
}
