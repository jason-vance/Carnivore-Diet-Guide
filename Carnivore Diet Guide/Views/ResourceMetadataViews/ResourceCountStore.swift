//
//  ResourceCountStore.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/23/26.
//

import Foundation
import Observation
import SwiftUI
import SwinjectAutoregistration

/// Like and comment counts for articles, recipes and posts, shared by every card and screen that shows them.
///
/// Each count view used to make its own provider in a plain property, so SwiftUI made a new one whenever the
/// screen around it redrew. The new one never fetched, and the count fell back to 0 until the card was rebuilt.
/// Counts live here instead, so a redraw keeps the count, a card scrolling back into view shows it right away,
/// and a count is fetched once however many views show it.
@MainActor
final class ResourceCountStore {

    /// One resource's count. Views read `count`, so only the views showing this resource redraw when it changes.
    @Observable
    @MainActor
    final class Entry {
        /// Nil until the first fetch succeeds.
        fileprivate(set) var count: UInt?
        @ObservationIgnored fileprivate var fetchedAt: Date?
        @ObservationIgnored fileprivate var isFetching = false
        @ObservationIgnored fileprivate var needsRefetch = false
    }

    /// How often a count on screen is fetched again.
    static let refreshInterval: Duration = .seconds(60)
    /// A count fetched this recently is reused rather than fetched again.
    static let freshFor: TimeInterval = 30

    private let fetchCount: (Resource) async throws -> UInt
    private var entries: [String: Entry] = [:]

    init(fetchCount: @escaping (Resource) async throws -> UInt) {
        self.fetchCount = fetchCount
    }

    func entry(for resource: Resource) -> Entry {
        let key = Self.key(for: resource)
        if let entry = entries[key] { return entry }
        let entry = Entry()
        entries[key] = entry
        return entry
    }

    /// Fetches the count unless it was fetched in the last `freshFor` seconds. `force` fetches it regardless,
    /// for right after the user likes or comments. A forced fetch during another fetch runs once that one ends,
    /// so the count can't be left at the value from before the change.
    func refresh(_ resource: Resource, force: Bool = false) async {
        let entry = entry(for: resource)
        if entry.isFetching {
            if force { entry.needsRefetch = true }
            return
        }
        if !force, let fetchedAt = entry.fetchedAt, Date.now.timeIntervalSince(fetchedAt) < Self.freshFor {
            return
        }

        entry.isFetching = true
        repeat {
            entry.needsRefetch = false
            do {
                let count = try await fetchCount(resource)
                entry.fetchedAt = .now
                if entry.count != count {
                    withAnimation(.snappy) { entry.count = count }
                }
            } catch {
                print("ResourceCountStore: couldn't load the count for \(resource.type.rawValue) \(resource.id). \(error.localizedDescription)")
            }
        } while entry.needsRefetch
        entry.isFetching = false
    }

    /// For the user's own like or comment: moves the count by `delta` right away, then checks it with the
    /// server a moment later, since the write behind it may not have reached the server yet.
    func adjust(_ resource: Resource, by delta: Int) async {
        let entry = entry(for: resource)
        if let count = entry.count {
            withAnimation(.snappy) { entry.count = UInt(max(0, Int(count) + delta)) }
        }
        try? await Task.sleep(for: .seconds(2))
        await refresh(resource, force: true)
    }

    /// Keeps the count current while the calling view is on screen. Run it from the view's `.task(id:)`.
    func keepCurrent(_ resource: Resource) async {
        while !Task.isCancelled {
            await refresh(resource)
            try? await Task.sleep(for: Self.refreshInterval)
        }
    }

    private static func key(for resource: Resource) -> String {
        "\(resource.type.rawValue)/\(resource.id)"
    }
}

extension ResourceCountStore {

    static let favorites = ResourceCountStore { resource in
        try await (iocContainer~>FavoriteCountProvider.self).favoriteCount(of: resource)
    }

    static let comments = ResourceCountStore { resource in
        try await (iocContainer~>CommentCountProvider.self).commentCount(of: resource)
    }
}

/// A like or comment count that stays current while it's on screen.
struct ResourceCountView: View {

    let resource: Resource
    let store: ResourceCountStore
    let icon: String

    var body: some View {
        let entry = store.entry(for: resource)
        MetadataItemView(
            text: "\(entry.count ?? 0)",
            icon: icon,
            isPlaceholder: entry.count == nil
        )
        .task(id: resource) {
            await store.keepCurrent(resource)
        }
    }
}
