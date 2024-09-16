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
    @Binding public var isWorking: Bool
    @State public var dismissResource: () -> ()
    
    @State private var showDeleteDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let resourceReporter = iocContainer~>ResourceReporter.self
    private let resourceDeleter = iocContainer~>ResourceDeleter.self

    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private var resourceIsMine: Bool {
        resource.author == userIdProvider.currentUserId
    }
    
    private func dismissOnMainThread() {
        DispatchQueue.main.async {
            dismissResource()
        }
    }
    
    private func reportResource() {
        guard let userId = userIdProvider.currentUserId else { return }
        
        isWorking = true
        
        Task {
            do {
                try await resourceReporter.reportResource(resource, reportedBy: userId)
                show(alertMessage: String(localized: "The report has been filed. It will be reviewed to make sure that our content guidelines are being followed."))
                DispatchQueue.main.async { isWorking = false }
            } catch {
                show(alertMessage: String(localized: "Failed to file report: \(error.localizedDescription)"))
            }
        }
    }
    
    private func deleteResource() {
        isWorking = true
        
        Task {
            do {
                try await resourceDeleter.delete(resource: resource)
                dismissOnMainThread()
                DispatchQueue.main.async { isWorking = false }
            } catch {
                show(alertMessage: String(localized: "Failed to delete: \(error.localizedDescription)"))
            }
        }
    }
    
    var body: some View {
        Menu {
            Text(resource.title)
            if resourceIsMine {
                DeleteResourceButton()
            } else {
                ReportResourceButton()
            }
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "ellipsis")
        }
        .alert(alertMessage, isPresented: $showAlert) {}
        .confirmationDialog(
            "\"\(resource.title)\"\n\nAre you sure you want to delete this? Once deleted, it can not be recovered.",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            ConfirmDeleteButton()
            CancelButton()
        }
    }
    
    @ViewBuilder func ReportResourceButton() -> some View {
        Button {
            reportResource()
        } label: {
            Label("Report", systemImage: "megaphone")
        }
    }
    
    @ViewBuilder func DeleteResourceButton() -> some View {
        Button {
            showDeleteDialog = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder func ConfirmDeleteButton() -> some View {
        Button("Delete", role: .destructive) {
            deleteResource()
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button("Cancel", role: .cancel) {}
    }
}

fileprivate func previewSetup(isMine: Bool, fails: Bool) {
    setupMockIocContainer(iocContainer)
    
    if isMine {
        iocContainer.autoregister(CurrentUserIdProvider.self) {
            let provider = MockCurrentUserIdProvider()
            provider.currentUserId = Resource.sample.author
            return provider
        }
    }
    
    if fails {
        iocContainer.autoregister(ResourceReporter.self) {
            let reporter = MockResourceReporter()
            reporter.error = "Test Failure"
            return reporter
        }
    }
}

@ViewBuilder fileprivate func ExtraOptionsButton_Preview() -> some View {
    ExtraOptionsButton(
        resource: .sample,
        isWorking: .constant(false),
        dismissResource: {}
    )
}

#Preview("isMine, Succeeds") {
    PreviewContainerWithSetup {
        previewSetup(isMine: true, fails: false)
    } content: {
        ExtraOptionsButton_Preview()
    }
}

#Preview("!isMine, Succeeds") {
    PreviewContainerWithSetup {
        previewSetup(isMine: false, fails: false)
    } content: {
        ExtraOptionsButton_Preview()
    }
}

#Preview("!isMine, Fails") {
    PreviewContainerWithSetup {
        previewSetup(isMine: false, fails: true)
    } content: {
        ExtraOptionsButton_Preview()
    }
}

#Preview("isMine, Fails") {
    PreviewContainerWithSetup {
        previewSetup(isMine: true, fails: true)
    } content: {
        ExtraOptionsButton_Preview()
    }
}
