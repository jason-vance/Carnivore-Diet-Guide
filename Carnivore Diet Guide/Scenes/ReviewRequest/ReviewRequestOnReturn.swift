//
//  ReviewRequestOnReturn.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import StoreKit

extension View {
    /// Asks for an App Store rating (see `ReviewRequestTrigger`) when the user comes back to this
    /// list from an article or recipe, so the prompt never interrupts reading.
    /// - Parameter navigationDepth: the list's `NavigationPath.count`.
    func requestsReviewOnReturn(navigationDepth: Int) -> some View {
        modifier(ReviewRequestOnReturn(navigationDepth: navigationDepth))
    }
}

private struct ReviewRequestOnReturn: ViewModifier {

    let navigationDepth: Int

    @Environment(\.requestReview) private var requestReview
    @AppStorage(ReviewRequestTrigger.lastRequestedDateKey) private var lastRequestedTimestamp: Double = 0

    private var lastRequestedDate: Date? {
        lastRequestedTimestamp > 0 ? Date(timeIntervalSince1970: lastRequestedTimestamp) : nil
    }

    func body(content: Content) -> some View {
        content.onChange(of: navigationDepth) { oldDepth, newDepth in
            guard oldDepth > 0, newDepth == 0 else { return }
            checkReviewRequest()
        }
    }

    private func checkReviewRequest() {
        let readLog = ContentReadLog.shared
        guard ReviewRequestTrigger.shouldRequest(
            contentReadCount: readLog.readCount,
            readingDayCount: readLog.readingDayCount,
            lastRequestedDate: lastRequestedDate
        ) else { return }

        // Marked now so coming back from another article right away doesn't queue a second request.
        lastRequestedTimestamp = Date.now.timeIntervalSince1970
        Task { @MainActor in
            // Let the pop transition finish so the prompt doesn't land mid-animation.
            try? await Task.sleep(for: .milliseconds(600))
            iocContainer.resolve(Analytics.self)?.logReviewRequested(contentReadCount: readLog.readCount)
            requestReview()
        }
    }
}
