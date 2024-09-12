//
//  SelectAuthorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import SwiftUI
import SwinjectAutoregistration

struct SelectAuthorView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let onSelect: (String) -> ()
    
    @State private var authors: [String] = []
    
    private let authorsFetcher = iocContainer~>PublishersFetcher.self
    
    private func fetchAuthors() {
        Task {
            do {
                let authors = try await authorsFetcher.fetchPublishers()
                withAnimation(.snappy) {
                    self.authors = authors
                }
            } catch {
                print("Failed to fetch authors: \(error.localizedDescription)")
                dismiss()
            }
        }
    }
    
    private func select(author: String) {
        onSelect(author)
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar("Select an Author")
            ScrollView {
                VStack {
                    ForEach(authors, id: \.self) { author in
                        Button {
                            select(author: author)
                        } label: {
                            ByLineView(userId: author)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.background)
        .onAppear { fetchAuthors() }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        SelectAuthorView() { selectedAuthor in }
    }
}
