//
//  CreateRecipeMetadataView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import SwiftUI
import SwinjectAutoregistration

struct CreateRecipeMetadataView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreateRecipeMetadataViewModel(
    )
    
    @State public var contentData: ContentData
    @Binding public var navigationPath: NavigationPath
    public let dismissAll: () -> ()
    
    @State private var summaryText: String = ""
    @State private var showPublicationDatePicker: Bool = false
    @State private var prepTimeText: String = ""
    @State private var cookTimeText: String = ""
    @State private var servingsText: String = ""
    @State private var showBasicNutritionInfoDialog: Bool = false
    @State private var showEditKeywordsDialog: Bool = false
    @State private var showDiscardDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var recipeMetadata: RecipeMetadata? {
        model.getRecipeMetadata(id: contentData.id)
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
    
    private var sortedKeywords: [SearchKeyword] {
        model.recipeSearchKeywords.sorted { $0.text < $1.text }
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
        guard let recipeMetadata = model.getRecipeMetadata(id: contentData.id) else {
            show(alertMessage: "Could not create RecipeMetadata")
            return
        }
        navigationPath.append(NewRecipeData(data: contentData, metadata: recipeMetadata))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            List {
                SummaryField()
                PublicationDateField()
                DifficultyField()
                PrepTimeCookTimeServingsField()
                NutritionField()
                SearchKeywordsField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden()
        .background(Color.background)
        .onChange(of: contentData, initial: true) { _, newData in
            model.set(title: newData.title, markdownContent: newData.markdownContent)
        }
        .onChange(of: summaryText, initial: false) { _, newSummaryText in
            model.recipeSummary = .init(newSummaryText)
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar {
            Text("Recipe Metadata")
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
        .disabled(recipeMetadata == nil)
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
                Text(model.recipePublicationDate.toBasicUiString())
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
                let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
                
                DatePicker(
                    "Publication Date",
                    selection: $model.recipePublicationDate,
                    in: tomorrow...,
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
    
    @ViewBuilder func PrepTimeCookTimeServingsField() -> some View {
        Section {
            LabeledContent("Prep Time") {
                TextField("Prep Time", text: $prepTimeText, prompt: Text("Minutes"))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, .paddingHorizontalButtonMedium)
                    .padding(.vertical, .paddingVerticalButtonMedium)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .stroke(style: .init(lineWidth: .borderWidthMedium))
                            .foregroundStyle(Color.accent)
                    }
                    .frame(width: 120)
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
            LabeledContent("Cook Time") {
                TextField("Cook Time", text: $cookTimeText, prompt: Text("Minutes"))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, .paddingHorizontalButtonMedium)
                    .padding(.vertical, .paddingVerticalButtonMedium)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .stroke(style: .init(lineWidth: .borderWidthMedium))
                            .foregroundStyle(Color.accent)
                    }
                    .frame(width: 120)
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
            LabeledContent("Servings") {
                TextField("Servings", text: $servingsText, prompt: Text("Servings"))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, .paddingHorizontalButtonMedium)
                    .padding(.vertical, .paddingVerticalButtonMedium)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .stroke(style: .init(lineWidth: .borderWidthMedium))
                            .foregroundStyle(Color.accent)
                    }
                    .frame(width: 120)
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
        } header: {
            Text("Cook Time & Servings")
                .foregroundStyle(Color.text)
        }
        .onChange(of: prepTimeText, initial: true) { _, prepTimeText in
            model.recipePrepTimeMinutes = UInt(prepTimeText)
        }
        .onChange(of: cookTimeText, initial: true) { _, cookTimeText in
            model.recipeCookTimeMinutes = UInt(cookTimeText)
        }
        .onChange(of: servingsText, initial: true) { _, servingsText in
            model.recipeServings = UInt(servingsText)
        }
    }
    
    @ViewBuilder func DifficultyField() -> some View {
        Section {
            Menu {
                DifficultyLevelButton(.beginner)
                DifficultyLevelButton(.intermediate)
                DifficultyLevelButton(.advanced)
            } label: {
                Text(model.recipeDifficultyLevel.toUiString())
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
        } header: {
            Text("Difficulty Level")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func DifficultyLevelButton(_ level: Recipe.DifficultyLevel) -> some View {
        Button {
            model.recipeDifficultyLevel = level
        } label: {
            HStack {
                Text(level.toUiString())
                Spacer()
                if model.recipeDifficultyLevel == level {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    @ViewBuilder func NutritionField() -> some View {
        Section {
            HStack {
                Button {
                    showBasicNutritionInfoDialog = true
                } label: {
                    if let nutritionInfo = model.recipeNutritionInfo {
                        Text(nutritionInfo.toSingleLineString())
                            .foregroundStyle(Color.accent)
                            .padding(.horizontal, .paddingHorizontalButtonMedium)
                            .padding(.vertical, .paddingVerticalButtonMedium)
                            .background {
                                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                                    .foregroundStyle(Color.accent.opacity(0.1))
                            }
                    } else {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Nutrition Info")
                        }
                        .foregroundStyle(Color.accent)
                        .bold()
                    }
                }
                .sheet(isPresented: $showBasicNutritionInfoDialog) {
                    BasicNutritionInfoCreatorView(nutritionInfo: $model.recipeNutritionInfo)
                        .padding(.top)
                        .presentationBackground(Color.background)
                        .presentationDragIndicator(.visible)
                }
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
        } header: {
            Text("Nutrition")
                .foregroundStyle(Color.text)
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
        let isHighlighted = model.recipeSearchKeywords.isEmpty
        
        Button {
            showEditKeywordsDialog = true
        } label: {
            Text("Edit \(model.recipeSearchKeywords.count) Keywords")
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
            EditKeywordsView(keywords: model.recipeSearchKeywords)
                .padding(.top)
                .presentationBackground(Color.background)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreateRecipeMetadataView(
            contentData: .sample,
            navigationPath: .constant(.init())
        ) {}
    }
}
