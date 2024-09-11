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
    
    public let keywords: Set<SearchKeyword>
    
    @State private var newKeywordText: String = ""
    @State private var newKeywordScore: String = ""

    private var newKeyword: SearchKeyword? {
        guard let score = UInt(newKeywordScore) else { return nil }
        return SearchKeyword(newKeywordText, score: score)
    }
    
    private var sortedKeywords: [SearchKeyword] {
        keywords
            .sorted { $0.text < $1.text }
            .sorted { $0.score > $1.score }
    }
    
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
            items: sortedKeywords,
            itemSpacing: 0
        ) { keyword in
            SearchKeywordItem(keyword)
                .id(keyword.id)
                .padding(.trailing, 8)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder func SearchKeywordItem(_ keyword: SearchKeyword) -> some View {
        KeywordItemButton(
            keyword: keyword,
            accessoryImage: "checkmark"
        ) { }
    }
}

#Preview {
    EditKeywordsView(keywords: SearchKeyword.samples)
}
