import Foundation
import WGCore

enum WGExteraBadgeSettings {
    /// Master switch: off means no requests at all and no badge drawn.
    static let enabled = WGSetting<Bool>("exteraBadge.enabled", default: true)
    /// Show the server's badge in the profile's info section.
    static let showInProfile = WGSetting<Bool>("exteraBadge.showInProfile", default: true)
    /// Show a compact pill next to the chat title in the chat list.
    static let showInChatList = WGSetting<Bool>("exteraBadge.showInChatList", default: true)
    /// Seconds between two full catalog requests (exteraGram uses ~10 minutes).
    static let refreshInterval = WGSetting<Int>("exteraBadge.refreshInterval", default: 600)
    /// Last good answer. Not exported: a cache, not a user preference.
    static let cache = WGSetting<WGExteraBadgeSnapshot>("exteraBadge.cache", default: WGExteraBadgeSnapshot(profiles: [], etag: nil, fetchedAt: 0), flags: [.noExport])

    static func declare() {
        let _ = WGExteraBadgeSettings.enabled
        let _ = WGExteraBadgeSettings.showInProfile
        let _ = WGExteraBadgeSettings.showInChatList
        let _ = WGExteraBadgeSettings.refreshInterval
        let _ = WGExteraBadgeSettings.cache
    }
}
