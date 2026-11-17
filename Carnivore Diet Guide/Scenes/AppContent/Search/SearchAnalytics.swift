//
//  SearchAnalytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/16/26.
//

import SwiftUI
import SwinjectAutoregistration

extension View {

    /// Logs a search once the text has stopped changing for a moment. Results update on every keystroke, so
    /// this keeps typing "salmon" to one search instead of six.
    ///
    /// The text itself is only logged when nothing matched, to show what people look for that isn't there yet.
    func logsSearch(
        _ searchText: String,
        of type: AnalyticsContentType,
        category: String? = nil,
        resultCount: @escaping () -> Int
    ) -> some View {
        task(id: searchText) {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            do {
                try await Task.sleep(for: .seconds(1.5))
            } catch {
                return
            }
            let count = resultCount()
            iocContainer.resolve(Analytics.self)?.logContentSearch(
                type: type,
                category: category,
                resultCount: count,
                unmatchedText: count == 0 ? text : nil
            )
        }
    }
}
