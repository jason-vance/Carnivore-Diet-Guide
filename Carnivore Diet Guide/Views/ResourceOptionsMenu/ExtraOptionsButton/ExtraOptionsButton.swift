//
//  ExtraOptionsButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ExtraOptionsButton: View {
    
    @State public var resource: Resource
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let resourceReporter = iocContainer~>ResourceReporter.self
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private var resourceIsMine: Bool {
        resource.authorUserId == userIdProvider.currentUserId
    }
    
    private func reportResource() {
        guard let userId = userIdProvider.currentUserId else { return }
        
        Task {
            do {
                try await resourceReporter.reportResource(resource, reportedBy: userId)
                show(alertMessage: String(localized: "The report has been filed. It will be reviewed to make sure that our content guidelines are being followed."))
            } catch {
                show(alertMessage: String(localized: "Failed to file report: \(error.localizedDescription)"))
            }
        }
    }
    
    var body: some View {
        Menu {
            Text(resource.title)
            if resourceIsMine {
                EditResourceButton()
                DeleteResourceButton()
            } else {
                ReportResourceButton()
            }
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "ellipsis")
        }
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func ReportResourceButton() -> some View {
        Button {
            reportResource()
        } label: {
            Label("Report", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func EditResourceButton() -> some View {
        Button {
            //TODO: Add ability to edit resource
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }
    
    @ViewBuilder func DeleteResourceButton() -> some View {
        Button {
            //TODO: Add ability to delete resource
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview("Default") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ExtraOptionsButton(resource: .sample)
    }
}

#Preview("Failing") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(ResourceReporter.self) {
            let reporter = MockResourceReporter()
            reporter.error = "Test Failure"
            return reporter
        }
    } content: {
        ExtraOptionsButton(resource: .sample)
    }
}
