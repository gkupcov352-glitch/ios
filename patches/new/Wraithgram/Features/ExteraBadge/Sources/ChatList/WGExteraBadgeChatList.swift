import Foundation
import UIKit
import SwiftSignalKit
import Postbox
import TelegramCore
import AccountContext
import ChatListUI
import WGCore
import WGHooks

/// Compact exteraGram badge next to the title of a user's chat row.
///
/// The catalog is public and anonymous; a row layout only reads the local cache. When the cache
/// changes, `accessoryPeers` re-lays out the listed peers once (not on a timer).
enum WGExteraBadgeChatList {
    private static let pillTag = 9932

    static func register() {
        WGChatListHooks.rowDidLayout.register({ layout in
            WGExteraBadgeChatList.updateRow(layout)
        })

        WGChatListHooks.accessoryPeers.register({ _ in
            return combineLatest(WGExteraBadgeSettings.enabled.signal, WGExteraBadgeSettings.cache.signal)
            |> map { enabled, snapshot -> Set<EnginePeer.Id> in
                guard enabled else {
                    return Set()
                }
                return Set(snapshot.profiles.compactMap { profile in
                    guard !profile.deleted, profile.displayText != nil else {
                        return nil
                    }
                    return EnginePeer.Id(namespace: Namespaces.Peer.CloudUser, id: EnginePeer.Id.Id._internalFromInt64Value(profile.id))
                })
            }
            |> distinctUntilChanged
        })
    }

    private static func updateRow(_ layout: WGChatListRowLayout) {
        guard WGExteraBadgeSettings.enabled.value, WGExteraBadgeSettings.showInChatList.value else {
            return
        }
        guard let peer = layout.peer, case let .user(user) = peer else {
            return
        }
        WGExteraBadgeStore.shared.refreshIfNeeded()
        guard let profile = WGExteraBadgeStore.shared.badge(for: user.id.id._internalGetInt64Value()), let text = profile.displayText else {
            return
        }

        let container = layout.node.view
        let pill: WGExteraBadgePillView
        if let existing = container.viewWithTag(pillTag) as? WGExteraBadgePillView {
            pill = existing
        } else {
            pill = WGExteraBadgePillView(frame: .zero)
            pill.tag = pillTag
            pill.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            container.addSubview(pill)
        }
        pill.update(text: text, color: profile.isDeveloper ? UIColor.systemPurple : UIColor.systemBlue)
        let size = pill.sizeThatFits(CGSize(width: 120, height: 15))
        pill.frame = CGRect(x: layout.titleFrame.maxX + 4, y: layout.titleFrame.midY - 8.0, width: size.width, height: 15.0)
    }
}
