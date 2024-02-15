//
//  HomeViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class HomeViewModel: ObservableObject {
    
    enum LoadingState {
        case idle
        case working
    }
    
    private let contentProvider = iocContainer~>HomeViewContentProvider.self
    
    @Published var loadingState: LoadingState = .idle
    @Published var content: HomeViewContent = .empty
    @Published var listDidAppear: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    func loadContent() {
        Task {
            loadingState = .working
            listDidAppear = false
            do {
                content = try await contentProvider.loadContent()
            } catch {
                show(alertMessage: "Unable to load: \(error.localizedDescription)")
            }
            loadingState = .idle
        }
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
