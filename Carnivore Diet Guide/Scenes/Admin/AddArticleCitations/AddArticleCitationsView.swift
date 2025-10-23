//
//  AddArticleCitationsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/22/25.
//

import SwiftUI

struct AddArticleCitationsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var articleCitationAdder: ArticleCitationAdder
    
    @State private var isWorking: Bool = false
    
    @State private var selectedArticle: Article? = nil
    
    @State private var citations: [Article.Citation] = []
    @State private var newCitationText: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var showArticleSelectorBinding: Binding<Bool> {
        .init(
            get: { selectedArticle == nil },
            set: { isShowing in }
        )
    }
    
    private var isFormValid: Bool {
        !citations.isEmpty && selectedArticle?.citations.isEmpty == true
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveAndDismiss() {
        isWorking = true
        Task {
            do {
                guard isFormValid else {
                    throw NSError(domain: "`citations` is empty or `article.citations` is not empty", code: 1234)
                }
                try await articleCitationAdder.add(citations: citations, toArticle: selectedArticle!)
                
                dismiss()
            } catch {
                let msg = "Failed to add citations to article: \(error.localizedDescription)"
                print(msg)
                show(alert: msg)
            }
            isWorking = false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                if let selectedArticle {
                    ArticleItemView(selectedArticle)
                        .articleStyle(.horizontal)
                        .listRowBackground(Color.background)
                        .listRowSeparator(.hidden)
                }
                CitationsField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(alertMessage, isPresented: $showAlert) {}
        .animation(.snappy, value: selectedArticle)
        .animation(.snappy, value: citations)
        .overlay {
            if isWorking {
                BlockingSpinnerView()
            }
        }
        .fullScreenCover(isPresented: showArticleSelectorBinding) {
            ArticleSelectorView {
                selectedArticle = $0
            }
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Add Citations") },
            leadingContent: BackButton,
            trailingContent: SaveAndDismissButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func SaveAndDismissButton() -> some View {
        NextButton { saveAndDismiss() }
            .disabled(!isFormValid)
    }
    
    @ViewBuilder private func CitationsField() -> some View {
            HStack {
                Text("Citations to add: \(citations.count)")
                Spacer()
            }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
            ForEach(citations) { citation in
                HStack {
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(Color.text)
                    Button {
                        openURL(citation.url)
                    } label: {
                        Text(citation.url.absoluteString)
                            .font(.caption)
                            .underline(true)
                            .foregroundStyle(Color.accentColor)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                citations.remove(atOffsets: indexSet)
            }
            NewCitationField()
    }
    
    @ViewBuilder func NewCitationField() -> some View {
        TextField(
            "New Citation",
            text: $newCitationText,
            prompt: Text("New Citation").foregroundStyle(Color.text.opacity(0.3))
        )
        .textContentType(.URL)
        .foregroundStyle(Color.text)
        .submitLabel(.next)
        .onSubmit {
            if let citation = Article.Citation(newCitationText) {
                citations.append(citation)
                newCitationText = ""
            } else {
                show(alert: "Not a valid citation")
            }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    AddArticleCitationsView()
        .environmentObject(ArticleCitationAdder.forTesting)
}
