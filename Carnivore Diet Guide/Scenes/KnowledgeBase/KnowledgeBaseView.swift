//
//  KnowledgeBaseView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import Kingfisher
import SwinjectAutoregistration

struct KnowledgeBaseView: View {
    
    private let prominentItemHeight: CGFloat = 150
    private let regularItemHeight: CGFloat = 100
    private let subduedItemHeight: CGFloat = 72
    private let margin: CGFloat = 16
    
    @State private var showSearchContent: Bool = false

    @StateObject private var model = KnowledgeBaseViewModel(
        topicProvider: iocContainer~>TopicProvider.self
    )
    
    @StateObject private var searchModel = KnowledgeBaseSearchViewModel(
    )
    
    @State var searchCategories: [ContentCategory] = ContentCategory.allCategories
    @State var selectedCategory: ContentCategory = .featured
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Knowledge Base"))
                ScrollView {
                    VStack {
                        SearchArea()
                        ListContent()
                    }
                }
                .overlay {
                    if model.isWorking {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accent)
                    }
                }
            }
            .background(Color.background)
            .alert(model.alertMessage, isPresented: $model.showAlert) {}
            .onAppear { model.fetchTopics() }
            .onChange(of: searchModel.searchPresented, initial: true) { _, showSearchContent in
                withAnimation(.snappy) {
                    self.showSearchContent = showSearchContent
                }
            }
        }
    }
    
    @ViewBuilder func SearchArea() -> some View {
        VStack(spacing: 0) {
            SearchBar(
                prompt: String(localized: "Articles, Guides, and more"),
                searchText: $searchModel.searchText,
                searchPresented: $searchModel.searchPresented,
                action: { searchModel.doSearch() }
            )
            .padding(.top)
            .padding(.horizontal)
            SearchCategoryPicker()
        }
    }
    
    @ViewBuilder func SearchCategoryPicker() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchCategories) { category in
                    let isSelected = selectedCategory == category
                    
                    Button {
                        withAnimation(.snappy) { selectedCategory = category }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.image)
                            Text(category.name)
                        }
                        .font(.caption.bold())
                        .foregroundStyle(isSelected ? Color.background : Color.accent)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundStyle(isSelected ? Color.accent : Color.accent.opacity(0.1))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if showSearchContent {
            SearchContent()
        } else {
            NonSearchContent()
        }
    }
    
    @ViewBuilder func SearchContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(searchModel.searchResults) { result in
                KnowledgeBaseSearchResultView(item: result)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func NonSearchContent() -> some View {
        ProminentTopicsSection()
        RegularTopicsSection()
        SubduedTopicsSection()
    }
    
    @ViewBuilder func ProminentTopicsSection() -> some View {
        Section {
            ForEach(model.prominentTopics) { topic in
                ProminentTopicRow(topic)
            }
        }
    }
    
    @ViewBuilder func ProminentTopicRow(_ topic: Topic) -> some View {
        ItemContent(text: topic.name, prominence: topic.prominence)
            .padding()
            .frame(height: prominentItemHeight)
            .containerRelativeFrame(.horizontal) { length, axes in
                return length - (2 * margin)
            }
            .background { ItemBackground(topic) }
            .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
    }
    
    @ViewBuilder private func RegularTopicsSection() -> some View {
        Section {
            ForEach(model.regularTopics) { topicPair in
                RegularTopicRow(topicPair)
            }
        }
    }
    
    @ViewBuilder private func RegularTopicRow(_ topicPair: Topic.Pair) -> some View {
        HStack(spacing: margin) {
            let left = topicPair.left
            ItemContent(text: left.name, prominence: left.prominence)
                .padding()
                .frame(height: regularItemHeight)
                .containerRelativeFrame(.horizontal) { length, axes in
                    return (length / 2) - (1.5 * margin)
                }
                .background { ItemBackground(left) }
                .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            if let right = topicPair.right {
                ItemContent(text: right.name, prominence: right.prominence)
                    .padding()
                    .frame(height: regularItemHeight)
                    .containerRelativeFrame(.horizontal) { length, axes in
                        return (length / 2) - (1.5 * margin)
                    }
                    .background { ItemBackground(right) }
                    .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder private func SubduedTopicsSection() -> some View {
        Section {
            ForEach(model.subduedTopics) { topicPair in
                SubduedTopicRow(topicPair)
            }
        }
    }
    
    @ViewBuilder private func SubduedTopicRow(_ topicPair: Topic.Pair) -> some View {
        HStack(spacing: margin) {
            let left = topicPair.left
            ItemContent(text: left.name, prominence: left.prominence)
                .padding()
                .frame(height: subduedItemHeight)
                .containerRelativeFrame(.horizontal) { length, axes in
                    return (length / 2) - (1.5 * margin)
                }
                .background { ItemBackground(left) }
                .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            if let right = topicPair.right {
                ItemContent(text: right.name, prominence: right.prominence)
                    .padding()
                    .frame(height: subduedItemHeight)
                    .containerRelativeFrame(.horizontal) { length, axes in
                        return (length / 2) - (1.5 * margin)
                    }
                    .background { ItemBackground(right) }
                    .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            }
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func ItemContent(text: String, prominence: Topic.Prominence) -> some View {
        let font: Font = {
            switch prominence {
            case .prominent:
                return .system(size: 24, weight: .bold)
            case .regular:
                return .system(size: 18, weight: .bold)
            case .subdued:
                return .system(size: 16, weight: .bold)
            }
        }()
        
        VStack {
            Spacer(minLength: 0)
            HStack {
                Text(text)
                    .font(font)
                    .lineLimit(2)
                    .foregroundStyle(Color.background)
                    .shadow(color: Color.black, radius: 2)
                Spacer(minLength: 0)
            }
        }
    }
    
    @ViewBuilder func ItemBackground(_ topic: Topic) -> some View {
        if let imageUrl = topic.imageUrl {
            KFImage(imageUrl)
                .resizable()
                .placeholder({Color.background.opacity(0.67)})
                .scaledToFill()
                .overlay(Color.text.opacity(0.67))
        } else {
            Rectangle()
                .foregroundStyle(Color.background.opacity(0.67))
                .overlay(Color.text.opacity(0.67))
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeBaseView()
    }
}
