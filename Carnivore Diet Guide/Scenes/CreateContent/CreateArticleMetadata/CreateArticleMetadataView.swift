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
    public let dismissAll: () -> ()
    
    @State private var summaryText: String = ""
    @State private var showPublicationDatePicker: Bool = false
    @State private var showAddCategoryDialog: Bool = false
    @State private var showEditKeywordsDialog: Bool = false
    @State private var showDiscardDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var contentMetadata: ContentMetadata? {
        model.getContentMetadata(id: contentData.id)
    }
    
    private var summaryInstructions: String {
        if summaryText.count == 0 {
            return String(localized: "Cannot be empty")
        }
        if summaryText.count < Resource.Summary.minTextLength {
            return String(localized: "Too short")
        }
        let count = "\(summaryText.count)/\(Resource.Summary.maxTextLength)"
        if summaryText.count > Resource.Summary.maxTextLength {
            return String(localized: "Too long, \(count)")
        }
        return count
    }
    
    private var sortedCategories: [Resource.Category] {
        model.articleCategories.sorted { $0.name < $1.name }
    }
    
    private var sortedKeywords: [SearchKeyword] {
        model.articleSearchKeywords.sorted { $0.text < $1.text }
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private func close() {
        if model.isFormChanged {
            showDiscardDialog = true
        } else {
            dismiss()
        }
    }
    
    private func goToNext() {
        guard let articleMetadata = model.getContentMetadata(id: contentData.id) else {
            show(alertMessage: "Could not create ContentMetadata")
            return
        }
        navigationPath.append(NewArticleData(data: contentData, metadata: articleMetadata))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            List {
                SummaryField()
                PublicationDateField()
                CategoriesField()
                SearchKeywordsField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden()
        .background(Color.background)
        .onChange(of: contentData, initial: true) { _, newData in
            model.set(markdownContent: newData.markdownContent)
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
            GoToNextButton()
        }
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            close()
        } label: {
            Image(systemName: "chevron.backward")
                .bold()
        }
        .confirmationDialog(
            "Do you want to discard your data?",
            isPresented: $showDiscardDialog,
            titleVisibility: .visible
        ) {
            DiscardButton()
            CancelButton()
        }
    }
    
    @ViewBuilder func DiscardButton() -> some View {
        Button("Discard", role: .destructive) {
            dismiss()
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button("Cancel", role: .cancel) { }
    }
    
    @ViewBuilder func GoToNextButton() -> some View {
        NextButton {
            goToNext()
        }
        .disabled(contentMetadata == nil)
    }
    
    @ViewBuilder func SummaryField() -> some View {
        Section {
            VStack(spacing: 0) {
                TextField(
                    "Summary",
                    text: $summaryText,
                    prompt: Text("Summary text").foregroundStyle(Color.text.opacity(0.3)),
                    axis: .vertical
                )
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(Color.text)
                HStack {
                    Spacer()
                    Text(summaryInstructions)
                        .font(.caption2)
                        .foregroundStyle(Color.text.opacity(0.5))
                }
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
        } header: {
            Text("Summary")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func PublicationDateField() -> some View {
        Section {
            Button {
                withAnimation(.snappy) {
                    showPublicationDatePicker.toggle()
                }
            } label: {
                Text(model.articlePublicationDate.toBasicUiString())
                    .foregroundStyle(Color.accent)
                    .padding(.horizontal, .paddingHorizontalButtonMedium)
                    .padding(.vertical, .paddingVerticalButtonMedium)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .foregroundStyle(Color.accent.opacity(0.1))
                    }
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
            if showPublicationDatePicker {
                DatePicker(
                    "Publication Date",
                    selection: $model.articlePublicationDate,
                    in: .now...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .foregroundStyle(Color.green)
                .preferredColorScheme(.light)
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
            }
        } header: {
            Text("Publication Date")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func CategoriesField() -> some View {
        Section {
            if !sortedCategories.isEmpty {
                ForEach(sortedCategories) { category in
                    RemoveCategoryButton(category)
                }
            }
            AddCategoryButton()
        } header: {
            Text("Categories")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func RemoveCategoryButton(_ category: Resource.Category) -> some View {
        Button {
            withAnimation(.snappy) {
                model.remove(category: category)
            }
        } label: {
            HStack {
                Image(systemName: "minus")
                    .foregroundStyle(Color.accent)
                ResourceCategoryView(category)
                Spacer()
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.background)
    }
    
    @ViewBuilder func AddCategoryButton() -> some View {
        let isHighlighted = model.articleCategories.isEmpty
        
        Button {
            showAddCategoryDialog = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Category")
            }
            .foregroundStyle(isHighlighted ? Color.background : Color.accent)
            .padding(.horizontal, isHighlighted ? .paddingHorizontalButtonMedium : 0)
            .padding(.vertical, isHighlighted ? .paddingVerticalButtonMedium : 0)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(isHighlighted ? Color.accent : Color.background)
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.background)
        .sheet(isPresented: $showAddCategoryDialog) {
            SelectCategoryView { selectedCategory in
                withAnimation(.snappy) {
                    model.add(category: selectedCategory)
                }
            }
            .padding(.top)
            .presentationBackground(Color.background)
        }
    }
    
    @ViewBuilder func SearchKeywordsField() -> some View {
        Section {
            AddSearchKeywordButton()
        } header: {
            Text("Search Keywords")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func AddSearchKeywordButton() -> some View {
        let isHighlighted = model.articleSearchKeywords.isEmpty
        
        Button {
            showEditKeywordsDialog = true
        } label: {
            Text("Edit \(model.articleSearchKeywords.count) Keywords")
                .foregroundStyle(isHighlighted ? Color.background : Color.accent)
                .padding(.horizontal, isHighlighted ? .paddingHorizontalButtonMedium : 0)
                .padding(.vertical, isHighlighted ? .paddingVerticalButtonMedium : 0)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(isHighlighted ? Color.accent : Color.background)
                }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
        .sheet(isPresented: $showEditKeywordsDialog) {
            EditKeywordsView(keywords: $model.articleSearchKeywords)
                .padding(.top)
                .presentationBackground(Color.background)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreateArticleMetadataView(
            contentData: .sample,
            navigationPath: .constant(.init())
        ) {}
    }
}
