import Foundation
import Postbox
import TelegramCore
import AccountContext
import WGCore
import WGHooks

enum WGQuickActionsDecorations {
    static func register() {
        // Late handler: append to whatever AntiDelete / Messages / Appearance already put into the
        // status line instead of replacing their marks.
        WGMessageDecorationHooks.decorations.register({ decoration, context in
            guard WGQuickActionsSettings.showMessageIdAndSeconds.value else {
                return
            }
            let marker = WGQuickActionsDecorations.marker(for: context.message)
            if let current = decoration.statusPrefix {
                decoration.statusPrefix = current + "· " + marker
            } else {
                decoration.statusPrefix = marker
            }
        }, order: 950)
    }

    private static func marker(for message: Message) -> String {
        let date = Date(timeIntervalSince1970: Double(message.timestamp))
        let components = Calendar(identifier: .gregorian).dateComponents([.hour, .minute, .second], from: date)
        let time = String(
            format: "%02d:%02d:%02d",
            components.hour ?? 0,
            components.minute ?? 0,
            components.second ?? 0
        )
        return "#\(message.id.id) \(time) "
    }
}
