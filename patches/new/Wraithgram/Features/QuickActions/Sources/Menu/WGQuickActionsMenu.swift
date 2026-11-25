import Foundation
import WGCore
import WGSettingsUI

/// Two rows in the existing chat-actions section. No new settings tab: both switches sit next to
/// Wraithgram's own «двойной тап — изменить».
enum WGQuickActionsMenu {
    static func register() {
        WGMenuRegistry.register(WGMenuRow(
            id: "quickActions.doubleTapRepeatToSaved",
            section: .swiftgramChatActions,
            order: 200,
            title: { "Двойной тап — повтор в Избранное" },
            subtitle: { "Как двойной тап — репост в Reza; работает после «двойной тап — изменить»" },
            icon: .system("arrow.right"),
            kind: .toggle(.global(WGQuickActionsSettings.doubleTapRepeatToSaved))
        ))
        WGMenuRegistry.register(WGMenuRow(
            id: "quickActions.showMessageIdAndSeconds",
            section: .swiftgramChatActions,
            order: 300,
            title: { "ID и секунды сообщения" },
            subtitle: { "В строке времени: #123 12:34:56 (идея из Reza)" },
            icon: .system("clock"),
            kind: .toggle(.global(WGQuickActionsSettings.showMessageIdAndSeconds))
        ))
    }
}
