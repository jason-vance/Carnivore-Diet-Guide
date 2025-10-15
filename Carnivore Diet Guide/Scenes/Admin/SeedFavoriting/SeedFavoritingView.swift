//
//  SeedFavoritingView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/14/25.
//

import SwiftUI
import SwinjectAutoregistration

struct SeedFavoritingView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @EnvironmentObject private var seedFavoriter: SeedFavoriter
    
    @State private var isWorking: Bool = false
    
    @State private var selectedArticle: Article? = nil
    
    @State private var publishers: [String] = []
    @State private var favoriters: [String] = []
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let publishersFetcher = iocContainer~>PublishersFetcher.self
    
    private var showArticleSelectorBinding: Binding<Bool> {
        .init(
            get: { selectedArticle == nil },
            set: { isShowing in }
        )
    }
    
    private var isFormValid: Bool {
        selectedArticle != nil && !favoriters.isEmpty
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    private func fetchAuthors() {
        Task {
            do {
                let publishers = try await publishersFetcher.fetchPublishers()
                self.publishers = publishers
            } catch {
                print("Failed to fetch authors: \(error.localizedDescription)")
                dismiss()
            }
        }
    }
    
    private func saveAndDismiss() {
        isWorking = true
        Task {
            do {
                guard isFormValid else {
                    throw NSError(domain: "article is nil or favoriters is empty", code: 1234)
                }
                try await seedFavoriter.favorite(article: selectedArticle!, withSeeds: favoriters)
                
                dismiss()
            } catch {
                let msg = "Failed to favorite article: \(error.localizedDescription)"
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
                RandomizeButton()
                ForEach(publishers, id: \.self) { publisher in
                    PublisherRow(publisher)
                }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(alertMessage, isPresented: $showAlert) {}
        .animation(.snappy, value: selectedArticle)
        .animation(.snappy, value: publishers)
        .animation(.snappy, value: favoriters)
        .onAppear(perform: fetchAuthors)
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
            primaryContent: { Text("Seed Favoriting") },
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
    
    @ViewBuilder private func RandomizeButton() -> some View {
        Button("Randomize") {
            var rand = SystemRandomNumberGenerator()
            let count = rand.next(upperBound: UInt(publishers.count - 2)) + 3 // At least 3, at most all
            
            favoriters = []
            publishers
                .shuffled()
                .prefix(Int(count))
                .forEach { favoriters.append($0) }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder private func PublisherRow(_ publisher: String) -> some View {
        Button {
            if favoriters.contains(publisher) {
                favoriters.removeAll(where: { $0 == publisher })
            } else {
                favoriters.append(publisher)
            }
        } label: {
            HStack {
                ByLineView(userId: publisher)
                Image(systemName: favoriters.contains(publisher) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    SeedFavoritingView()
        .environmentObject(SeedFavoriter.forTesting)
}
