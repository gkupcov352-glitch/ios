import Foundation
import WGCore
import WGSettingsUI

/// Rows in the existing «Профиль и Настройки › Профиль» section. No new tab is needed: the badge
/// is a small profile/chat-list decoration, not a separate settings world.
enum WGExteraBadgeMenu {
    static func register() {
        WGMenuRegistry.register(WGMenuRow(
            id: "exteraBadge.enabled",
            section: .swiftgramProfilesInfo,
            order: 400,
            title: { "Бейджи exteraGram" },
            subtitle: { "Статусы SUPPORTER / DEVELOPER из публичного API exteraGram" },
            icon: .system("rosette"),
            kind: .toggle(.global(WGExteraBadgeSettings.enabled))
        ))
        WGMenuRegistry.register(WGMenuRow(
            id: "exteraBadge.inProfile",
            section: .swiftgramProfilesInfo,
            order: 410,
            title: { "Бейдж в профиле" },
            kind: .toggle(.global(WGExteraBadgeSettings.showInProfile)),
            isVisible: { _ in WGExteraBadgeSettings.enabled.value }
        ))
        WGMenuRegistry.register(WGMenuRow(
            id: "exteraBadge.inChatList",
            section: .swiftgramProfilesInfo,
            order: 420,
            title: { "Бейдж в списке чатов" },
            kind: .toggle(.global(WGExteraBadgeSettings.showInChatList)),
            isVisible: { _ in WGExteraBadgeSettings.enabled.value }
        ))
        WGMenuRegistry.register(WGMenuRow(
            id: "exteraBadge.refresh",
            section: .swiftgramProfilesInfo,
            order: 430,
            title: { "Обновить список бейджей" },
            subtitle: { "Запрос к api.exteragram.app (только публичный список)" },
            icon: .system("arrow.triangle.2.circlepath"),
            kind: .action({ context in
                WGExteraBadgeStore.shared.refreshIfNeeded(force: true)
                context.presentToast("Запрос к exteraGram отправлен")
            }),
            label: { _ in
                let count = WGExteraBadgeStore.shared.snapshot.profiles.count
                return count > 0 ? "\(count)" : "—"
            },
            isVisible: { _ in WGExteraBadgeSettings.enabled.value }
        ))
    }
}
