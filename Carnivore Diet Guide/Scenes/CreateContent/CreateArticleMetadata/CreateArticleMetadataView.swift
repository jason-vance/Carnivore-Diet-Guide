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
    @Binding public var navigationPath: NavigationPath
    
    @State private var summaryText: String = ""
    @State private var showAddCategoryDialog: Bool = false
    @State private var showAddKeywordDialog: Bool = false
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
                SummaryField()
                CategoriesField()
                SearchKeywordsField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden()
        .background(Color.background)
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
        //TODO: Add discard dialog
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
    
    @ViewBuilder func SummaryField() -> some View {
        Section("Summary") {
            VStack(spacing: 0) {
                TextField(
                    "Summary",
                    text: $summaryText,
                    prompt: Text("Summary text in TextField").foregroundStyle(Color.text.opacity(0.3)),
                    axis: .vertical
                )
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(Color.text)
                HStack {
                    Spacer()
                    Text("\(summaryText.count)/\(Resource.Summary.maxTextLength)")
                        .font(.caption2)
                        .foregroundStyle(Color.text.opacity(0.5))
                }
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
        }
    }
    
    @ViewBuilder func CategoriesField() -> some View {
        Section("Categories") {
            ForEach(model.articleCategories) { category in
                ResourceCategoryView(category)
            }
            AddCategoryRow()
        }
    }
    
    @ViewBuilder func AddCategoryRow() -> some View {
        Button {
            showAddCategoryDialog = true
        } label: {
            //TODO: Highlight this if categories is empty
            HStack {
                Image(systemName: "plus")
                Text("Category")
            }
            .foregroundStyle(Color.accent)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
        .sheet(isPresented: $showAddCategoryDialog) {
            SelectCategoryView { selectedCategory in
                model.add(category: selectedCategory)
            }
        }
    }
    
    @ViewBuilder func SearchKeywordsField() -> some View {
        Section("Search Keywords") {
            //TODO: Add KeywordCloud
            //TODO: Allow removing of keywords
            AddSearchKeyword()
        }
    }
    
    @ViewBuilder func AddSearchKeyword() -> some View {
        Button {
            showAddKeywordDialog = true
        } label: {
            //TODO: Highlight this if keywords is empty
            HStack {
                Image(systemName: "plus")
                Text("Keyword")
            }
            .foregroundStyle(Color.accent)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
        //TODO: Add AddKeywordDialog
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreateArticleMetadataView(
            contentData: .sample,
            navigationPath: .constant(.init())
        )
    }
}
