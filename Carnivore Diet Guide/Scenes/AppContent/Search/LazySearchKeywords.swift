//
//  LazySearchKeywords.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/16/26.
//

import Foundation

/// An article's or recipe's search keywords, worked out the first time they're needed.
///
/// Finding keywords lemmatizes the whole text, which takes a few milliseconds per article or recipe. Doing it as
/// each one was created froze the app for a second or more at launch, while the cached recipes and articles loaded
/// on the main thread. Only search uses keywords, so now they wait for search, and `prepare(_:)` works them out in
/// the background once a list is on screen so the first search doesn't have to.
final class LazySearchKeywords: @unchecked Sendable {

    private let lock = NSLock()
    private var text: (() -> String)?
    private var cached: Set<SearchKeyword>?

    /// `text` is called once, the first time the keywords are needed.
    init(text: @escaping () -> String) {
        self.text = text
    }

    var keywords: Set<SearchKeyword> {
        lock.lock()
        defer { lock.unlock() }
        if let cached { return cached }
        let keywords = SearchKeyword.keywordsFrom(string: text?() ?? "")
        cached = keywords
        text = nil
        return keywords
    }

    /// Works out the keywords in the background. Ones already worked out are skipped.
    static func prepare(_ all: [LazySearchKeywords]) {
        guard !all.isEmpty else { return }
        Task.detached(priority: .utility) {
            for keywords in all {
                _ = keywords.keywords
            }
        }
    }
}

/// Keywords come from the text they belong to, so two resources with the same text have the same keywords. The
/// text is compared on its own, so the keywords don't need to be.
extension LazySearchKeywords: Hashable {
    static func == (lhs: LazySearchKeywords, rhs: LazySearchKeywords) -> Bool { true }
    func hash(into hasher: inout Hasher) { }
}
