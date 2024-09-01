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
    
    private func add(keyword: SearchKeyword) {
        keywords.insert(keyword)
        newKeywordText = ""
        newKeywordScore = ""
    }
    
    private func remove(keyword: SearchKeyword) {
        keywords.remove(keyword)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar("Edit Search Keywords")
            KeywordField()
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
    
    @ViewBuilder func KeywordField() -> some View {
        HStack {
            TextField(
                "New Keyword",
                text: $newKeywordText,
                prompt: Text("Keyword").foregroundStyle(Color.text.opacity(0.3))
            )
            .keyboardType(.alphabet)
            .padding(.horizontal, .paddingHorizontalButtonMedium)
            .padding(.vertical, .paddingVerticalButtonMedium)
            .frame(height: .barHeight)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthThin))
                    .foregroundStyle(Color.accent)
            }
            TextField(
                "Relevance Score",
                text: $newKeywordScore,
                prompt: Text("Score").foregroundStyle(Color.text.opacity(0.3))
            )
            .keyboardType(.numberPad)
            .padding(.horizontal, .paddingHorizontalButtonMedium)
            .padding(.vertical, .paddingVerticalButtonMedium)
            .frame(width: 2 * .barHeight, height: .barHeight)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthThin))
                    .foregroundStyle(Color.accent)
            }
            Button {
                if let newKeyword = newKeyword {
                    withAnimation(.snappy) {
                        add(keyword: newKeyword)
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .bold()
                    .foregroundStyle(Color.background)
                    .frame(width: .barHeight, height: .barHeight)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                            .foregroundStyle(newKeyword == nil ? Color.gray : Color.accent)
                    }
            }
            .disabled(newKeyword == nil)
        }
        .foregroundStyle(Color.text)
        .padding(.horizontal, .paddingHorizontalButtonMedium)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            BarDivider()
        }
    }
    
    @ViewBuilder func KeywordCloud() -> some View {
        FlowLayout(
            mode: .scrollable,
            items: sortedKeywords,
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
