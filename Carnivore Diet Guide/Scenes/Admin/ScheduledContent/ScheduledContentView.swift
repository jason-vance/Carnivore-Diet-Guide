//
//  ScheduledContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/18/26.
//

import SwiftUI

/// Admin: the articles and recipes dated in the future, by the day they go live. Tapping one previews it without
/// the paywall, and without logging views of something that isn't live yet.
struct ScheduledContentView: View {

    @Environment(\.dismiss) private var dismiss: DismissAction

    private let fetcher: ScheduledContentFetcher

    init(fetcher: ScheduledContentFetcher = .forProd) {
        self.fetcher = fetcher
    }

    private enum LoadState {
        case loading
        case loaded(ScheduledContent)
        case failed(String)
    }

    private enum Item: Identifiable {
        case article(Article)
        case recipe(Recipe)

        var id: String {
            switch self {
            case .article(let article): "article-\(article.id)"
            case .recipe(let recipe): "recipe-\(recipe.id)"
            }
        }

        var publicationDate: Date {
            switch self {
            case .article(let article): article.publicationDate
            case .recipe(let recipe): recipe.publicationDate
            }
        }
    }

    private struct Day: Identifiable {
        let date: Date
        let items: [Item]
        var id: Date { date }
    }

    @State private var loadState: LoadState = .loading
    @State private var navigationPath = NavigationPath()

    private func days(in content: ScheduledContent) -> [Day] {
        let items = content.articles.map(Item.article) + content.recipes.map(Item.recipe)
        let calendar = Calendar.current
        return Dictionary(grouping: items) { calendar.startOfDay(for: $0.publicationDate) }
            .map { date, items in
                Day(date: date, items: items.sorted { $0.publicationDate < $1.publicationDate })
            }
            .sorted { $0.date < $1.date }
    }

    private func load() async {
        do {
            let content = try await fetcher.fetchScheduledContent()
            withAnimation(.snappy) { loadState = .loaded(content) }
        } catch {
            withAnimation(.snappy) { loadState = .failed(error.localizedDescription) }
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Scheduled"), leadingContent: CloseButton)
                Content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.background)
            .navigationDestination(for: Article.self) { article in
                Preview { ArticleView(article: article) }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                Preview { RecipeView(recipe: recipe) }
            }
        }
        .task { await load() }
    }

    @ViewBuilder private func Preview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Preview"), leadingContent: BackButton)
            ScrollView {
                content()
                    .padding(.bottom)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder private func BackButton() -> some View {
        Button {
            navigationPath.removeLast()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }

    @ViewBuilder private func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }

    @ViewBuilder private func Content() -> some View {
        switch loadState {
        case .loading:
            ProgressView()
                .tint(Color.text)
        case .failed(let message):
            Message(
                systemImage: "exclamationmark.triangle",
                title: String(localized: "Couldn't load scheduled content"),
                detail: message
            ) {
                Button(String(localized: "Try Again")) {
                    loadState = .loading
                    Task { await load() }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        case .loaded(let content) where content.isEmpty:
            ScrollView {
                Message(
                    systemImage: "calendar",
                    title: String(localized: "Nothing scheduled"),
                    detail: String(localized: "Articles and recipes dated after now show up here until they go live.")
                ) { EmptyView() }
                .padding(.top, 120)
            }
            .refreshable { await load() }
        case .loaded(let content):
            ContentList(content)
        }
    }

    @ViewBuilder private func ContentList(_ content: ScheduledContent) -> some View {
        List {
            ForEach(days(in: content)) { day in
                Section {
                    ForEach(day.items) { item in
                        ItemRow(item)
                    }
                } header: {
                    DayHeader(day.date)
                }
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .refreshable { await load() }
        .safeAreaInset(edge: .top, spacing: 0) {
            Text(summary(of: content))
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.background)
        }
    }

    private func summary(of content: ScheduledContent) -> String {
        let articles = content.articles.count == 1
            ? String(localized: "1 article")
            : String(localized: "\(content.articles.count) articles")
        let recipes = content.recipes.count == 1
            ? String(localized: "1 recipe")
            : String(localized: "\(content.recipes.count) recipes")
        let last = (content.articles.map(\.publicationDate) + content.recipes.map(\.publicationDate)).max() ?? .now
        let through = last.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        return String(localized: "\(articles) and \(recipes) scheduled, through \(through).")
    }

    @ViewBuilder private func DayHeader(_ date: Date) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: date).day ?? 0
        HStack(alignment: .firstTextBaseline) {
            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.subheadline.bold())
                .foregroundStyle(Color.text)
            Spacer()
            Text(days <= 0 ? String(localized: "Later today") : days == 1 ? String(localized: "Tomorrow") : String(localized: "In \(days) days"))
                .font(.caption)
                .foregroundStyle(Color.text.opacity(0.6))
        }
        .textCase(nil)
    }

    @ViewBuilder private func ItemRow(_ item: Item) -> some View {
        Button {
            switch item {
            case .article(let article): navigationPath.append(article)
            case .recipe(let recipe): navigationPath.append(recipe)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ItemKindLabel(item)
                switch item {
                case .article(let article):
                    // Article cards lead with the summary, so the title goes above it.
                    Text(article.title)
                        .font(.headline)
                        .foregroundStyle(Color.text)
                        .multilineTextAlignment(.leading)
                    ArticleItemView(article)
                        .articleStyle(.horizontal)
                case .recipe(let recipe):
                    RecipeItemView(recipe)
                        .recipeStyle(.horizontal)
                }
            }
        }
        .buttonStyle(.pressable)
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }

    private func ItemKindLabel(_ item: Item) -> some View {
        let isPremium: Bool
        let label: Label<Text, Image>
        switch item {
        case .article(let article):
            isPremium = article.isPremium
            label = Label(String(localized: "Article"), systemImage: "doc.text")
        case .recipe(let recipe):
            isPremium = recipe.isPremium
            label = Label(String(localized: "Recipe"), systemImage: "fork.knife")
        }
        return HStack(spacing: 8) {
            label
            Text(isPremium ? String(localized: "Carnivore+") : String(localized: "Free"))
                .foregroundStyle(isPremium ? Color.accentColor : Color.text.opacity(0.6))
            Spacer()
            Text(item.publicationDate.formatted(date: .omitted, time: .shortened))
                .foregroundStyle(Color.text.opacity(0.6))
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.text.opacity(0.8))
    }

    @ViewBuilder private func Message<Actions: View>(
        systemImage: String,
        title: String,
        detail: String,
        @ViewBuilder actions: () -> Actions
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.text)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.7))
                .multilineTextAlignment(.center)
            actions()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Scheduled") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ScheduledContentView(fetcher: .forTesting)
    }
}

#Preview("Nothing scheduled") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ScheduledContentView(fetcher: .forTestingWithNothing)
    }
}
