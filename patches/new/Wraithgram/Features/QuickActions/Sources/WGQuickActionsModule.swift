import Foundation

/// Entry point of WGQuickActions.
///
/// Ideas come from other iOS mods (Reza/Regram-ios: double-tap actions and message ids with
/// seconds). The implementation is original and uses only Wraithgram's public WGHooks surface;
/// no code from those projects is copied and no submodule is edited. Registration happens from
/// `WGFeatures.registerAll()`, before `WGHookRegistry.freeze()`.
public enum WGQuickActionsModule {
    public static func register() {
        WGQuickActionsSettings.declare()
        WGQuickActionsMenu.register()
        WGQuickActionsGestures.register()
        WGQuickActionsDecorations.register()
    }
}
