import Foundation

/// Entry point of WGExteraBadge — the real public exteraGram badge feed in Wraithgram.
///
/// Based on the API contract of exteraGram (https://github.com/exteraSquad/exteraGram,
/// `api.exteragram.app/api/v1/profiles`). No badge is granted locally: the app only displays
/// what the exteraGram server says. Registration happens from `WGFeatures.registerAll()`, before
/// `WGHookRegistry.freeze()`.
public enum WGExteraBadgeModule {
    public static func register() {
        WGExteraBadgeSettings.declare()
        WGExteraBadgeMenu.register()
        WGExteraBadgeProfile.register()
        WGExteraBadgeChatList.register()
        _ = WGExteraBadgeStore.shared
    }
}
