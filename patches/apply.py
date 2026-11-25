#!/usr/bin/env python3
"""Apply the Wraithgram mod patches to a clean Wraithgram checkout.

Usage:
    python patches/apply.py <path-to-wraithgram-ios-root> [--fresh-ui] [--patch-name NAME]

What it does:
  * copies every file under patches/new/Wraithgram/ into Wraithgram/;
  * copies every file under patches/new/Root/ into the checkout root (e.g. a simulator workflow);
  * makes small, exact edits in a few Wraithgram files;
  * generates unified patches in patches/generated/ for inspection or for `git apply`.

The script is idempotent: already applied edits are skipped. Nothing is committed.
"""

import argparse
import difflib
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
NEW_WRAITHGRAM = HERE / "new" / "Wraithgram"
NEW_ROOT_FILES = HERE / "new" / "Root"
GENERATED = HERE / "generated"

BASE_PATCH = "wg-mod.patch"
FRESH_PATCH = "wg-mod-with-fresh-ui.patch"
LEGACY_BASE_PATCH = "wg-extera-badge.patch"
LEGACY_FRESH_PATCH = "wg-extera-badge-with-fresh-ui.patch"

FEATURES_BUILD = "Wraithgram/Features/BUILD"
FEATURES_SWIFT = "Wraithgram/Features/Sources/WGFeatures.swift"
ABOUT_SWIFT = "Wraithgram/WGSettingsUI/Sources/Screens/WGSettingsDataScreens.swift"
APPEARANCE_SWIFT = "Wraithgram/Features/Appearance/Settings/Sources/WGAppearanceSettings.swift"

REPLACEMENTS = [
    (
        FEATURES_BUILD,
        '        "//Wraithgram/Features/SessionBackup:WGSessionBackup",\n',
        '        "//Wraithgram/Features/SessionBackup:WGSessionBackup",\n'
        '        "//Wraithgram/Features/ExteraBadge:WGExteraBadge",\n',
        "Features BUILD: add WGExteraBadge dependency",
    ),
    (
        FEATURES_BUILD,
        '        "//Wraithgram/Features/ExteraBadge:WGExteraBadge",\n',
        '        "//Wraithgram/Features/ExteraBadge:WGExteraBadge",\n'
        '        "//Wraithgram/Features/QuickActions:WGQuickActions",\n',
        "Features BUILD: add WGQuickActions dependency",
    ),
    (
        FEATURES_SWIFT,
        "import WGSessionBackup\n",
        "import WGSessionBackup\nimport WGExteraBadge\n",
        "WGFeatures.swift: import WGExteraBadge",
    ),
    (
        FEATURES_SWIFT,
        "import WGExteraBadge\n",
        "import WGExteraBadge\nimport WGQuickActions\n",
        "WGFeatures.swift: import WGQuickActions",
    ),
    (
        FEATURES_SWIFT,
        "        WGSessionBackupModule.register()\n",
        "        WGSessionBackupModule.register()\n        WGExteraBadgeModule.register()\n",
        "WGFeatures.swift: register WGExteraBadge",
    ),
    (
        FEATURES_SWIFT,
        "        WGExteraBadgeModule.register()\n",
        "        WGExteraBadgeModule.register()\n        WGQuickActionsModule.register()\n",
        "WGFeatures.swift: register WGQuickActions",
    ),
    (
        ABOUT_SWIFT,
        """    WGMenuRegistry.register(WGMenuRow(
        id: "menu.about.source",
        section: .aboutLicense,
        order: 100,
        title: { WGStrings.Menu.About.sourceCode },
        icon: .bundle("Chat/Context Menu/Browser"),
        kind: .action({ menuContext in
            menuContext.context.sharedContext.applicationBindings.openUrl(wgSourceCodeUrl)
        })
    ))
""",
        """    WGMenuRegistry.register(WGMenuRow(
        id: "menu.about.source",
        section: .aboutLicense,
        order: 100,
        title: { WGStrings.Menu.About.sourceCode },
        icon: .bundle("Chat/Context Menu/Browser"),
        kind: .action({ menuContext in
            menuContext.context.sharedContext.applicationBindings.openUrl(wgSourceCodeUrl)
        })
    ))
    // The badge feed of this build comes from the public exteraGram API. Credit the project
    // as required by exteraGram's ADDITIONAL_TERMS.md; this is not an exteraGram build.
    WGMenuRegistry.register(WGMenuRow(
        id: "menu.about.exteraGramBadges",
        section: .aboutLicense,
        order: 150,
        title: { "Badge service: exteraGram" },
        subtitle: { "https://github.com/exteraSquad/exteraGram" },
        icon: .bundle("Chat/Context Menu/Browser"),
        kind: .action({ menuContext in
            menuContext.context.sharedContext.applicationBindings.openUrl("https://github.com/exteraSquad/exteraGram")
        })
    ))
""",
        "About: attribute exteraGram badge service",
    ),
]

FRESH_UI_REPLACEMENTS = [
    (
        APPEARANCE_SWIFT,
        'public static let bubbleIncomingRadius = WGSetting<Double>("appearance.bubbles.incomingRadius", default: 16.0)',
        'public static let bubbleIncomingRadius = WGSetting<Double>("appearance.bubbles.incomingRadius", default: 18.0)',
        "Fresh UI: incoming bubble radius 18",
    ),
    (
        APPEARANCE_SWIFT,
        'public static let bubbleOutgoingRadius = WGSetting<Double>("appearance.bubbles.outgoingRadius", default: 16.0)',
        'public static let bubbleOutgoingRadius = WGSetting<Double>("appearance.bubbles.outgoingRadius", default: 18.0)',
        "Fresh UI: outgoing bubble radius 18",
    ),
    (
        APPEARANCE_SWIFT,
        'public static let stickerSize = WGSetting<Double>("appearance.stickers.size", default: 100.0)',
        'public static let stickerSize = WGSetting<Double>("appearance.stickers.size", default: 110.0)',
        "Fresh UI: sticker size 110%",
    ),
]


def copy_tree(source_root: Path, destination_root: Path, prefix: str, copied: list, new_files: dict):
    """Copy text files and remember their checkout-relative paths for the patch."""
    if not source_root.is_dir():
        return
    for source in sorted(source_root.rglob("*")):
        if not source.is_file():
            continue
        relative = source.relative_to(source_root).as_posix().replace("\\", "/")
        target_relative = (prefix + "/" + relative) if prefix else relative
        content = source.read_text(encoding="utf-8")
        new_files[target_relative] = content
        destination = destination_root / Path(relative)
        if destination.exists() and destination.read_bytes() == source.read_bytes():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        copied.append(target_relative)


def apply_replacements(root: Path, items, originals: dict, applied: list, skipped: list):
    for relative, old, new, label in items:
        path = root / Path(relative)
        if not path.exists():
            raise SystemExit(f"Missing expected file in Wraithgram checkout: {relative}")
        text = path.read_text(encoding="utf-8")
        originals.setdefault(relative, text)
        if new in text:
            skipped.append(label)
            continue
        if old not in text:
            raise SystemExit(f"Cannot apply [{label}]: anchor not found in {relative}")
        path.write_bytes(text.replace(old, new, 1).encode("utf-8"))
        applied.append(label)


def unified_diff(path_text: str, new_text: str, relative: str) -> str:
    return "".join(
        difflib.unified_diff(
            path_text.splitlines(keepends=True),
            new_text.splitlines(keepends=True),
            fromfile=f"a/{relative}",
            tofile=f"b/{relative}",
        )
    )


def write_patch(data: bytes, patch_name: str) -> Path:
    GENERATED.mkdir(parents=True, exist_ok=True)
    names = {patch_name}
    if patch_name == BASE_PATCH:
        names.add(LEGACY_BASE_PATCH)
    if patch_name == FRESH_PATCH:
        names.add(LEGACY_FRESH_PATCH)
    for name in sorted(names):
        (GENERATED / name).write_bytes(data)
    return GENERATED / patch_name


def generate_patch(root: Path, originals: dict, new_files: dict, patch_name: str) -> Path:
    chunks = []
    for relative in sorted(new_files):
        content = new_files[relative]
        chunks.append(f"diff --git a/{relative} b/{relative}\nnew file mode 100644\n")
        chunks.append(unified_diff("", content, relative))
    for relative in sorted(originals):
        current = (root / Path(relative)).read_text(encoding="utf-8")
        diff = unified_diff(originals[relative], current, relative)
        if diff:
            chunks.append(f"diff --git a/{relative} b/{relative}\n")
            chunks.append(diff)
    return write_patch("".join(chunks).encode("utf-8"), patch_name)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", type=Path, help="root of the Wraithgram/ios checkout")
    parser.add_argument("--fresh-ui", action="store_true", help="also change a few appearance defaults")
    parser.add_argument("--patch-name", default=None, help=f"patch filename in patches/generated/ (default: {FRESH_PATCH} with --fresh-ui, else {BASE_PATCH})")
    args = parser.parse_args()

    root = args.repo.resolve()
    if not (root / "Wraithgram" / "Features").is_dir():
        raise SystemExit(f"Not a Wraithgram iOS checkout: {root}")

    patch_name = args.patch_name or (FRESH_PATCH if args.fresh_ui else BASE_PATCH)
    copied, applied, skipped, originals, new_files = [], [], [], {}, {}
    copy_tree(NEW_WRAITHGRAM, root / "Wraithgram", "Wraithgram", copied, new_files)
    copy_tree(NEW_ROOT_FILES, root, "", copied, new_files)

    apply_replacements(root, REPLACEMENTS, originals, applied, skipped)
    if args.fresh_ui:
        apply_replacements(root, FRESH_UI_REPLACEMENTS, originals, applied, skipped)

    print(f"New/updated module files: {len(copied)}")
    for label in applied:
        print(f"  applied: {label}")
    for label in skipped:
        print(f"  already applied: {label}")

    if not copied and not applied:
        print("Nothing changed; the existing unified patches were left untouched.")
        print("No commit or push was made. Build with GitHub Actions as described in docs/BUILD.md.")
        return 0

    patch = generate_patch(root, originals, new_files, patch_name)
    print(f"Unified patch written to: {patch}")
    print("No commit or push was made. Build with GitHub Actions as described in docs/BUILD.md.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
