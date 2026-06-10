# macdaily

A native macOS app for writing **one markdown note per day**. Each day gets its own file (`2026-06-10.md`) in a folder you choose. Optional daily reminders nudge you to write.

## Install

### Option A — Build from source (recommended)

No Gatekeeper warnings when you build locally.

```bash
git clone https://github.com/andresousadotpt/macdaily.git
cd macdaily
make app
open dist/macdaily.app
```

Requirements: macOS 14 (Sonoma) or later, Xcode Command Line Tools. Full Xcode is needed for `make test`.

### Option B — Homebrew

```bash
brew tap andresousadotpt/tap
brew install --cask macdaily
```

If macOS blocks launch the first time, right-click `macdaily.app` → **Open**, or use System Settings → Privacy & Security → **Open Anyway**.

Build from source (Option A) avoids this entirely.

### Option C — GitHub Release

Download `macdaily-{version}.zip` from [Releases](https://github.com/andresousadotpt/macdaily/releases), unzip, and open the app. Same Gatekeeper note as Option B.

## Usage

1. Launch macdaily and choose a notes folder.
2. Today's note is created automatically — on launch, at local midnight, when the Mac wakes, and when the app returns to the foreground.
3. Use the **menu bar icon** (book) for quick access: edit today's note in the popover or click **Open macdaily** for the full window.
4. Pick earlier days from the sidebar.
5. Open **Settings** (⌘,) to change the notes folder, configure daily reminders, customize appearance, or back up settings.

Settings are saved automatically to `~/Library/Application Support/MacDaily/config.json`. Use **Settings → Backup** to export or import a JSON file (appearance, shortcuts, reminders, and startup — not your notes folder path).

### Appearance

Settings → **Appearance** lets you adjust:

- **Editor zoom** — slider or **⌘+** / **⌘−** / **⌘0** (View menu) to zoom in, out, or reset
- **Theme** — light, dark, or follow system; optional high-contrast text
- **Editor** — font style, line spacing, margins, line numbers, default editor/split/preview view
- **Preview formatting** — pick a preset theme (GitHub, Monokai, Dracula, One Dark, Nord, Tokyo Night, Gruvbox, Solarized, Ocean, Forest, and more) or switch to **Custom** to fine-tune each element
- **Sidebar** — show or hide the daily note count

### Formatting & shortcuts

Use **Format** menu shortcuts (defaults shown) or change them in Settings → **Shortcuts**:

| Action | Default shortcut |
| ------ | ---------------- |
| Bold | ⌘B |
| Italic | ⌘I |
| Strikethrough | ⌘⇧X |
| Underline | ⌘U (inserts HTML tags) |
| Inline code | ⌘E |
| Link | ⌘K |
| Heading 1–6 | ⌘⌥1 … ⌘⌥6 |

The editor can show **line numbers** in a left gutter (toggle in Settings → Appearance).

Code blocks in the preview use **syntax highlighting** when you specify a language (e.g. ` ```swift `). Click the **copy** icon on a code block to copy its contents.

Closing the main window keeps macdaily running in the **menu bar** so you can keep jotting notes from there.

On first launch, macdaily asks for **notification permission**, a **notes folder**, and whether to **open at login** (on by default). Change startup behavior anytime in Settings → General.

### Reminders

Default reminder times are **9:30 AM**, **1:00 PM**, and **4:00 PM** (your Mac's local time). You can add, edit, or remove times in Settings → Reminders. macOS will ask for notification permission the first time reminders are enabled.

Reminders only work when running the packaged app (`make app` → `open dist/macdaily.app`). They are skipped under `make run` / `swift run`, which does not run inside a proper `.app` bundle.

## Development

```bash
make build    # debug build
make run      # build and launch via swift run (reminders skipped)
make test     # unit tests (requires full Xcode, not Command Line Tools alone)
make app      # release .app in ./dist — use this to test reminders
make clean    # remove build artifacts
```

## Releasing

Version lives in `packaging/Info.plist` (`CFBundleShortVersionString`). Push to `main` and GitHub Actions will:

1. Auto-bump the patch version if `v{current}` already exists (e.g. `0.1.0` → `0.1.1`)
2. Build `macdaily.app` (ad-hoc signed)
3. Publish a GitHub Release zip
4. Update the Homebrew cask in [homebrew-tap](https://github.com/andresousadotpt/homebrew-tap)

For a **minor** or **major** release, bump locally first:

```bash
make bump-version BUMP=minor   # or BUMP=major
git add packaging/Info.plist && git commit -m "chore: bump version to X.Y.Z"
```

Then merge to `main`. CI will use that version as-is (no tag exists yet) and publish it.

### CI secrets

| Secret | Required | Purpose |
| ------ | -------- | ------- |
| `HOMEBREW_TAP_TOKEN` | For automated tap updates | GitHub PAT with `contents: write` on `homebrew-tap` |

Apple Developer ID / notarization is **not** required. Releases are ad-hoc signed.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, code guidelines, and pull request expectations.

| Document | Purpose |
| -------- | ------- |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [SUPPORT.md](SUPPORT.md) | Help, FAQs, and where to ask questions |
| [SECURITY.md](SECURITY.md) | Report vulnerabilities privately |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community standards |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [AGENTS.md](AGENTS.md) | Architecture reference for developers and AI agents |

## License

MIT — see [LICENSE](LICENSE).
