load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

# Feature module WGExteraBadge: the real public exteraGram badge catalog in Wraithgram.
# Never depends on TelegramUI or another WG<Feature> module (FOUNDATION_SPEC §1.1).
swift_library(
    name = "WGExteraBadge",
    module_name = "WGExteraBadge",
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
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Postbox:Postbox",
        "//submodules/TelegramCore:TelegramCore",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ChatListUI:ChatListUI",
        "//submodules/TelegramPresentationData:TelegramPresentationData",
    ],
    visibility = [
        "//visibility:public",
    ],
)
