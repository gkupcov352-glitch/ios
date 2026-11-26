import Foundation
import UIKit
import AsyncDisplayKit
import TelegramCore
import WGCore
import WGHooks

/// Badge in a user's profile: an info row plus a compact pill beside the name.
///
/// The status always comes from the public exteraGram catalog. Opening a profile may start a
/// rate-limited refresh; the next layout draws the answer. Nothing is granted locally.
enum WGExteraBadgeProfileUI {
    private static let pillTag = 9931

    static func register() {
        WGPeerInfoHooks.infoRows.register({ info in
            return WGExteraBadgeProfileUI.rows(info)
        }, order: 120)

        WGPeerInfoHooks.headerDidLayout.register({ header in
            WGExteraBadgeProfileUI.updateHeader(header)
        }, order: 120)
    }

    private static func rows(_ info: WGPeerInfoContext) -> [WGPeerInfoRow] {
        guard WGExteraBadgeSettings.enabled.value, WGExteraBadgeSettings.showInProfile.value, !info.isSettings else {
            return []
        }
        guard case let .user(user) = info.peer else {
            return []
        }
        WGExteraBadgeStore.shared.refreshIfNeeded()
        guard let profile = WGExteraBadgeStore.shared.badge(for: user.id.id._internalGetInt64Value()) else {
            return []
        }
        guard let text = profile.displayText else {
            return []
        }
        let label = profile.isDeveloper ? "Разработчик exteraGram" : "Саппортер exteraGram"
        return [WGPeerInfoRow(id: "exteraBadge.profile", label: label, text: text)]
    }

    private static func updateHeader(_ header: WGPeerInfoHeader) {
        guard WGExteraBadgeSettings.enabled.value, WGExteraBadgeSettings.showInProfile.value, !header.isSettings, let peer = header.peer else {
            return
        }
        guard case let .user(user) = peer else {
            return
        }
        WGExteraBadgeStore.shared.refreshIfNeeded()
        guard let profile = WGExteraBadgeStore.shared.badge(for: user.id.id._internalGetInt64Value()), let text = profile.displayText else {
            return
        }

        // The header exposes the name's own views; fall back to the header itself.
        let container = header.titleStateViews.last ?? header.node.view
        let pill: WGExteraBadgePillView
        if let existing = container.viewWithTag(pillTag) as? WGExteraBadgePillView {
            pill = existing
        } else {
            pill = WGExteraBadgePillView(frame: CGRect(x: container.bounds.width + 4, y: 0, width: 0, height: 17))
            pill.tag = pillTag
            pill.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            container.addSubview(pill)
        }
        let color = profile.isDeveloper ? UIColor.systemPurple : UIColor.systemBlue
        pill.update(text: text, color: color)
        let size = pill.sizeThatFits(CGSize(width: 160, height: 17))
        pill.frame.size = CGSize(width: size.width, height: 17)
    }
}
