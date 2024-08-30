//
//  CreateArticleMetadataView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI
import SwinjectAutoregistration

struct CreateArticleMetadataView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreateArticleMetadataViewModel(
    )
    
    @State public var contentData: ContentData
    @State public var navigationPath: NavigationPath
    
    @State private var summaryText: String = ""
    @State private var showDiscardDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private func close() {
        if model.isFormEmpty {
            dismiss()
        } else {
            showDiscardDialog = true
        }
    }
    
    private func goToNext() {
        //TODO: Implement CreateArticleMetadataView.goToNext()
//        guard let postData = model.contentData else {
//            show(alertMessage: "Could not create ReviewPostData")
//            return
//        }
//        navigationPath.append(postData)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            List {
                
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: summaryText, initial: false) { _, newSummaryText in
            model.articleSummary = .init(newSummaryText)
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar {
            Text("Article Metadata")
        } leadingContent: {
            BackButton()
        } trailingContent: {
            NextButton()
        }
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            close()
        } label: {
            Image(systemName: "chevron.backward")
                .bold()
        }
    }
    
    @ViewBuilder func NextButton() -> some View {
        Button {
            goToNext()
        } label: {
            Text("Next")
                .foregroundStyle(Color.background)
                .font(.caption.bold())
                .padding(8)
                .background() {
                    Capsule()
                        .foregroundStyle(model.contentMetadata == nil ? Color.gray : Color.accent)
                }
        }
        .disabled(model.contentMetadata == nil)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreateArticleMetadataView(
            contentData: .sample,
            navigationPath: .init()
        )
    }
}
