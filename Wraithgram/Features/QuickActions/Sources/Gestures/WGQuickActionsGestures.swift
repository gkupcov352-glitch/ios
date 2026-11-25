import Foundation
import UIKit
import SwiftSignalKit
import Postbox
import TelegramCore
import AccountContext
import TelegramPresentationData
import UndoUI
import WGCore
import WGHooks
import WGFeaturesShared

enum WGQuickActionsGestures {
    static func register() {
        // WGMessages' «double tap → edit» is registered at order 0 and returns true only when it
        // actually handled the tap. Our handler runs after it (order 50), so enabling both is safe.
        WGMessageGestureHooks.tap.register({ request in
            guard request.tapCount == 2, WGQuickActionsSettings.doubleTapRepeatToSaved.value else {
                return false
            }
            // Saved Messages → Saved Messages would only create duplicates.
            guard request.message.id.peerId != request.context.account.peerId else {
                return false
            }
            WGQuickActionsGestures.repeatToSaved(request.message, context: request.context)
            return true
        }, order: 50)
    }

    /// Forwards one message to the account's Saved Messages using the same pipeline as the existing
    /// «В Избранное» menu item (including copy fallbacks for protected media).
    private static func repeatToSaved(_ message: Message, context: AccountContext) {
        WGForwardSend.send(
            account: context.account,
            messages: [message],
            to: [WGForwardSend.Target(peerId: context.account.peerId, threadId: nil)],
            hideNames: false,
            hideCaptions: false,
            completion: { result in
                let text = result.messages.isEmpty
                    ? "Не удалось добавить сообщение в Избранное"
                    : "Сообщение добавлено в Избранное"
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                context.sharedContext.mainWindow?.present(UndoOverlayController(
                    presentationData: presentationData,
                    content: .info(title: nil, text: text, timeout: nil, customUndoText: nil),
                    elevatedLayout: false,
                    action: { _ in false }
                ), on: .root)
            }
        )
    }
}
