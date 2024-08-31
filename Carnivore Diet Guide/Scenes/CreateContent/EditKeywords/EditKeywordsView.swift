//
//  EditKeywordsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI
import SwiftUIFlowLayout

struct EditKeywordsView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @Binding public var keywords: Set<SearchKeyword>
    
    private func remove(keyword: SearchKeyword) {
        keywords.remove(keyword)
    }
    
    //TODO: Add keywords
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar("Edit Search Keywords")
            ScrollView {
                VStack {
                    KeywordCloud()
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
    }
    
    @ViewBuilder func KeywordCloud() -> some View {
        FlowLayout(
            mode: .scrollable,
            items: keywords.sorted { $0.text < $1.text },
            itemSpacing: 0
        ) { keyword in
            RemoveSearchKeywordButton(keyword)
                .id(keyword.id)
                .padding(.trailing, 8)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder func RemoveSearchKeywordButton(_ keyword: SearchKeyword) -> some View {
        KeywordItemButton(
            keyword: keyword,
            accessoryImage: "xmark"
        ) {
            withAnimation(.snappy) {
                remove(keyword: keyword)
            }
        }
    }
}

#Preview {
    StatefulPreviewContainer(SearchKeyword.samples) { keywords in
        EditKeywordsView(keywords: keywords)
    }
}
