//
//  FeaturedArticlesCreatorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import SwiftUI

struct FeaturedArticlesCreatorView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var publicationDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
    @State private var sections: [FeaturedArticles.Section] = []
    
    @State private var showPublicationDatePicker: Bool = false
    @State private var showNewSectionCreator: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                PublicationDateField()
                SectionsField()
            }
            //TODO: I think I want to make all listStyles .grouped
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            String(localized: "Featured Articles"),
            leadingContent: BackButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func PublicationDateField() -> some View {
        Section {
            Button {
                withAnimation(.snappy) {
                    showPublicationDatePicker.toggle()
                }
            } label: {
                Text(publicationDate.toBasicUiString())
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
                    selection: $publicationDate,
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
    
    @ViewBuilder func SectionsField() -> some View {
        Section {
            ForEach(sections) { section in
                FeaturedArticlesSectionRow(section)
            }
            .onDelete { sections.remove(atOffsets: $0) }
            AddSectionButton()
        } header: {
            Text("Featured Content Sections")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func FeaturedArticlesSectionRow(_ section: FeaturedArticles.Section) -> some View {
        VStack(alignment:.leading) {
            HStack {
                Text(section.title.title)
                    .font(.title.weight(.heavy))
                Spacer()
            }
            if let description = section.description {
                Text(description.description)
                    .font(.subheadline)
            }
            Text("Layout: \(section.layout.displayName)")
                .font(.caption2)
            
            if !section.primaryContent.isEmpty {
                Text("Primary Content (\(section.primaryContent.count))")
                    .font(.headline)
                ForEach(section.primaryContent) { item in
                    Text(item.article.title)
                        .lineLimit(1)
                        .font(.subheadline)
                }
            }
            if !section.secondaryContent.isEmpty {
                Text("Secondary Content (\(section.secondaryContent.count))")
                    .font(.headline)
                ForEach(section.secondaryContent) { item in
                    Text(item.article.title)
                        .lineLimit(1)
                        .font(.subheadline)
                }
            }
            if !section.tertiaryContent.isEmpty {
                Text("Tertiary Content (\(section.tertiaryContent.count))")
                    .font(.headline)
                ForEach(section.tertiaryContent) { item in
                    Text(item.article.title)
                        .lineLimit(1)
                        .font(.subheadline)
                }
            }
        }
        .foregroundStyle(Color.text)
        .padding()
        .background(Color.background)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        .clipped()
        .shadow(color: Color.text, radius: 4)
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func AddSectionButton() -> some View {
        Button {
            showNewSectionCreator = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Section")
            }
            .bold()
            .foregroundStyle(Color.accent)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
        .fullScreenCover(isPresented: $showNewSectionCreator) {
            FeaturedArticleSectionCreatorView() { newSection in
                sections.append(newSection)
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FeaturedArticlesCreatorView()
    }
}
