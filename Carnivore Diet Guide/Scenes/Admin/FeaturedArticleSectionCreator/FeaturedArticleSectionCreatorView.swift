//
//  FeaturedArticleSectionCreatorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import SwiftUI

struct FeaturedArticleSectionCreatorView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let saveAction: (FeaturedArticles.Section) -> ()
    
    @State private var layout: FeaturedArticles.Section.Layout = .collage
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var items: [FeaturedArticles.Section.Item] = []
    
    @State private var showAddPrimaryArticle: Bool = false
    @State private var showAddSecondaryArticle: Bool = false
    @State private var showAddTertiaryArticle: Bool = false

    private var section: FeaturedArticles.Section? {
        guard let title = FeaturedSectionTitle(title) else { return nil }
        let description = FeaturedSectionDescription(description)
        
        return .init(
            id: UUID(),
            layout: layout,
            title: title,
            description: description,
            content: items
        )
    }
    
    private func saveAndDismiss() {
        guard let section = section else { return }
        saveAction(section)
        dismiss()
    }
    
    private func remove(items: [FeaturedArticles.Section.Item]) {
        let ids = items.map { $0.id }
        self.items.removeAll { ids.contains($0.id) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                TitleField()
                DescriptionField()
                LayoutField()
                ContentField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Featured Section") },
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
        NextButton(action: saveAndDismiss)
            .disabled(section == nil)
    }
    
    @ViewBuilder func TitleField() -> some View {
        TextField(
            "Title",
            text: $title,
            prompt: Text("Title").foregroundStyle(Color.text.opacity(0.3))
        )
        .textInputAutocapitalization(.words)
        .font(.title.bold())
        .foregroundStyle(Color.text)
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func DescriptionField() -> some View {
        TextField(
            "Description",
            text: $description,
            prompt: Text("Description").foregroundStyle(Color.text.opacity(0.3))
        )
        .textInputAutocapitalization(.sentences)
        .font(.body)
        .foregroundStyle(Color.text)
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func LayoutField() -> some View {
        Section {
            Menu {
                ForEach(FeaturedArticles.Section.Layout.allCases, id: \.self) { layout in
                    LayoutMenuOption(layout)
                }
            } label: {
                Text(layout.displayName)
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
            Text("Layout")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func LayoutMenuOption(_ layout: FeaturedArticles.Section.Layout) -> some View {
        Button {
            self.layout = layout
        } label: {
            HStack {
                Text(layout.displayName)
                if self.layout == layout {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    @ViewBuilder func ContentField() -> some View {
        switch layout {
        case .collage: CollageContentField()
        }
    }
    
    @ViewBuilder func CollageContentField() -> some View {
        let primary = items.filter { $0.prominence == .primary }
        let secondary = items.filter { $0.prominence == .secondary }
        let tertiary = items.filter { $0.prominence == .tertiary }
        
        Section {
            ForEach(primary) { item in
                SectionItemView(item)
            }
            .onDelete { indexSet in remove(items: indexSet.map { primary[$0] }) }
            AddPrimaryArticleButton()
        } header: {
            Text("Primary Articles (\(primary.count)):")
                .foregroundStyle(Color.text)
        }
        Section {
            let columns = [
                GridItem.init(.adaptive(minimum: 100, maximum: 300)),
                GridItem.init(.adaptive(minimum: 100, maximum: 300))
            ]
            
            ForEach(secondary) { item in
                SectionItemView(item)
            }
            .onDelete { indexSet in remove(items: indexSet.map { secondary[$0] }) }
            AddSecondaryArticleButton()
        } header: {
            Text("Secondary Articles (\(secondary.count)):")
                .foregroundStyle(Color.text)
        }
        Section {
            ForEach(tertiary) { item in
                SectionItemView(item)
            }
            .onDelete { indexSet in remove(items: indexSet.map { tertiary[$0] }) }
            AddTertiaryArticleButton()
        } header: {
            Text("Tertiary Articles (\(tertiary.count)):")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func SectionItemView(
        _ item: FeaturedArticles.Section.Item
    ) -> some View {
        ArticleItemView(item.article)
            .articleStyle(.horizontal)
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func AddPrimaryArticleButton() -> some View {
        AddArticleButton {
            showAddPrimaryArticle = true
        }
        .fullScreenCover(isPresented: $showAddPrimaryArticle) {
            ArticleSelectorView { article in
                items.append(.init(id: UUID(), article: article, prominence: .primary))
            }
        }
    }
    
    @ViewBuilder func AddSecondaryArticleButton() -> some View {
        AddArticleButton {
            showAddSecondaryArticle = true
        }
        .fullScreenCover(isPresented: $showAddSecondaryArticle) {
            ArticleSelectorView { article in
                items.append(.init(id: UUID(), article: article, prominence: .secondary))
            }
        }
    }
    
    @ViewBuilder func AddTertiaryArticleButton() -> some View {
        AddArticleButton {
            showAddTertiaryArticle = true
        }
        .fullScreenCover(isPresented: $showAddTertiaryArticle) {
            ArticleSelectorView { article in
                items.append(.init(id: UUID(), article: article, prominence: .tertiary))
            }
        }
    }
    
    @ViewBuilder func AddArticleButton(action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Article")
            }
            .foregroundStyle(Color.accent)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    FeaturedArticleSectionCreatorView { newSection in
        
    }
}
