import Foundation
import SwiftSignalKit
import WGCore

/// Cache and refresh policy of the public exteraGram catalog.
///
/// Main thread. Refreshes at most once per `refreshInterval` (10 minutes — the same order as
/// exteraGram's `BadgesController`), reuses the ETag, and keeps the last good snapshot on any
/// failure. The cache is `.noExport`: it is public data, not a user setting.
final class WGExteraBadgeStore {
    static let shared = WGExteraBadgeStore()

    private var inFlight = false
    private var lastRefresh: Int32 = 0
    private let disposables = DisposableSet()

    private init() {
    }

    static func now() -> Int32 {
        return Int32(clamping: Int(Date().timeIntervalSince1970))
    }

    var snapshot: WGExteraBadgeSnapshot {
        return WGExteraBadgeSettings.cache.value
    }

    func badge(for userId: Int64) -> WGExteraBadgeProfile? {
        guard WGExteraBadgeSettings.enabled.value else {
            return nil
        }
        return self.snapshot.profile(for: userId)
    }

    func badgeText(for userId: Int64) -> String? {
        return self.badge(for: userId)?.displayText
    }

    /// Called when a profile opens and from the settings screen. `force` is used by the
    /// «Обновить» row.
    func refreshIfNeeded(force: Bool = false) {
        assert(Thread.isMainThread)
        guard WGExteraBadgeSettings.enabled.value, !self.inFlight else {
            return
        }
        let now = WGExteraBadgeStore.now()
        let last = max(self.lastRefresh, self.snapshot.fetchedAt)
        if !force, last > 0, now - last < Int32(WGExteraBadgeSettings.refreshInterval) {
            return
        }
        self.inFlight = true
        let etag = self.snapshot.etag
        self.disposables.add((WGExteraBadgeAPI.fetch(etag: etag)
        |> deliverOnMainQueue).start(next: { [weak self] result in
            guard let self else {
                return
            }
            self.inFlight = false
            self.lastRefresh = WGExteraBadgeStore.now()
            switch result {
            case let .updated(snapshot):
                WGExteraBadgeSettings.cache.set(snapshot)
            case .notModified:
                break
            case .failed:
                break
            }
        }))
    }
}
