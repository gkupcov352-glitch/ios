import Foundation
import WGCore

enum WGQuickActionsSettings {
    /// Double tap repeats the message into Saved Messages instead of the quick reaction.
    /// Wraithgram's own «double tap → edit» (order 0) keeps priority when both are enabled.
    static let doubleTapRepeatToSaved = WGSetting<Bool>("quickActions.doubleTapRepeatToSaved", default: false)
    /// Append `#<id> <HH:mm:ss>` before the time in every message's status line.
    static let showMessageIdAndSeconds = WGSetting<Bool>("quickActions.showMessageIdAndSeconds", default: false)

    static func declare() {
        let _ = WGQuickActionsSettings.doubleTapRepeatToSaved
        let _ = WGQuickActionsSettings.showMessageIdAndSeconds
    }
}
