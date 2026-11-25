load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

# Feature module WGQuickActions: two small Reza-inspired conveniences implemented with the
# existing WGHooks surface:
#   - double tap on a message → repeat it to Saved Messages;
#   - show the message id and the timestamp with seconds in the status line.
# No upstream/submodule edits. Never depends on TelegramUI or another WG<Feature> module.
swift_library(
    name = "WGQuickActions",
    module_name = "WGQuickActions",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//Wraithgram/WGCore:WGCore",
        "//Wraithgram/WGHooks:WGHooks",
        "//Wraithgram/WGSettingsUI:WGSettingsUI",
        "//Wraithgram/Features/Shared:WGFeaturesShared",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Postbox:Postbox",
        "//submodules/TelegramCore:TelegramCore",
        "//submodules/AccountContext:AccountContext",
        "//submodules/TelegramPresentationData:TelegramPresentationData",
        "//submodules/UndoUI:UndoUI",
    ],
    visibility = [
        "//visibility:public",
    ],
)
