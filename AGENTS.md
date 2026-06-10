# AGENTS.md

Instructions for AI coding agents working on **macdaily** — a native macOS app for writing one markdown note per day.

## Project overview

- **What it does:** Each calendar day gets its own note file (`2026-06-10.md`) in a user-chosen folder. The app runs in the menu bar, supports daily reminders, and provides a markdown editor with live preview.
- **Platform:** macOS 14 (Sonoma) or later only. Swift Package Manager project; no Xcode project file.
- **License:** MIT
- **Repo:** https://github.com/andresousadotpt/macdaily

## Architecture

Two Swift targets with a strict separation of concerns:

| Target | Role | Depends on |
|--------|------|------------|
| **MacDailyCore** | Models, persistence, pure logic (no UI) | Foundation only |
| **MacDaily** | SwiftUI views, AppKit bridges, menu bar, notifications | MacDailyCore, MarkdownUI, Splash |

```
Sources/
├── MacDailyCore/          # Testable, UI-free core
│   ├── Models/            # Codable settings, DailyNote, shortcuts, themes
│   ├── Services/          # NoteStore, ConfigStore (actors)
│   └── Utilities/         # DateFormatting, MarkdownFormatting, AtomicWrite
└── MacDaily/              # macOS app shell
    ├── MacDailyApp.swift  # @main entry, menus, AppDelegate
    ├── ViewModels/        # AppViewModel, EditorViewModel (@Observable)
    ├── Views/             # SwiftUI screens and settings
    ├── MenuBar/           # Status bar icon and popover
    ├── Notifications/     # ReminderManager (UserNotifications)
    ├── Support/           # AppKit bridges, themes, window helpers
    └── Resources/         # Bundled assets (Logo.png, etc.)
```

### Key design choices

- **View models** use `@MainActor @Observable` (Observation framework, not Combine).
- **Persistence** uses `actor` types (`NoteStore`, `ConfigStore`) for thread-safe file I/O.
- **File writes** always go through `AtomicWrite` — never write note or config files directly.
- **Daily notes** are plain `.md` files named `yyyy-MM-dd.md` in the user's notes folder (see `DateFormatting`).
- **App config** lives at `~/Library/Application Support/MacDaily/config.json` (`AppPaths.configURL`).
- **Settings export/import** uses `SettingsExport` and intentionally excludes the notes folder path.

### UI stack

- **SwiftUI** for windows, settings, sidebar, and onboarding.
- **AppKit** where SwiftUI is insufficient: `MarkdownTextEditor` (`NSViewRepresentable` wrapping `NSTextView`), `LineNumberRulerView`, menu bar (`NSStatusItem`).
- **MarkdownUI** for preview rendering; **Splash** for syntax highlighting in preview code blocks.
- Cross-layer events use `NotificationCenter` (e.g. `.applyMarkdownFormat`, `.openMainWindow`).

## Build and run

All commands run from the repo root:

```bash
make build    # swift build (debug)
make run      # build + swift run MacDaily
make test     # swift test — requires full Xcode, not Command Line Tools alone
make app      # release .app bundle in ./dist/
make clean    # remove .build/ and dist/
```

### Important runtime gotchas

1. **Reminders and notifications only work in a real `.app` bundle.** `make run` / `swift run` skips them (`ReminderManager.isAvailable` checks `Bundle.main.bundleURL.pathExtension == "app"`). To test reminders, use `make app && open dist/macdaily.app`.
2. **Closing the main window does not quit the app.** It stays in the menu bar (`applicationShouldTerminateAfterLastWindowClosed` returns `false`).
3. **Day rollover** is handled by `DayRolloverMonitor` (midnight, wake, foreground) — changes here affect when today's note is auto-created.
4. **Onboarding order:** notification permission → notes folder → launch-at-login preference.

## Testing

Tests live in `Tests/MacDailyCoreTests/` and target **MacDailyCore only**. UI and AppKit code is not unit-tested.

```bash
make test
# or focus one test:
swift test --filter MacDailyCoreTests.testFilenameUsesIsoDate
```

### What to test in MacDailyCore

- Date/filename parsing (`DateFormatting`)
- Markdown formatting toggles (`MarkdownFormatting`)
- Note store CRUD (`NoteStore` with temp directories)
- Config encoding/decoding defaults (`AppConfig`, `SettingsExport`)
- Reminder time deduplication (`ReminderTime`)

Use temporary directories for file I/O tests and clean up in `defer`. Prefer deterministic dates (fixed `DateComponents` with explicit calendar/time zone) over `Date()`.

### What not to test here

- SwiftUI view layout, AppKit text views, notification delivery, or menu bar behavior — these require manual QA via `make app`.

## Code style and conventions

### Swift language

- **Swift tools version:** 6.0 (`Package.swift`).
- **Minimum deployment:** macOS 14.
- Prefer `Sendable`, `Codable`, and `Equatable` on models in MacDailyCore.
- Use `public` on MacDailyCore types and methods consumed by the app target.
- Mark UI-only types `internal` (default) in MacDaily.

### Naming and organization

- New **models/settings** → `Sources/MacDailyCore/Models/`
- New **file I/O or config logic** → `Sources/MacDailyCore/Services/` or `Utilities/`
- New **screens** → `Sources/MacDaily/Views/`
- New **AppKit bridges or styling** → `Sources/MacDaily/Support/`
- Keep view models thin: orchestration in `AppViewModel`, per-editor state in `EditorViewModel`.

### Patterns to follow

```swift
// Persist config after mutation
config = updated
try await configStore.save(config)

// Debounce note saves (see EditorViewModel, AppViewModel menu bar path)
debouncer.schedule(delay: 0.3) { await save() }

// Actor calls from MainActor
let contents = try await noteStore?.readContents(of: note)
```

### Patterns to avoid

- Do not add UI imports (`SwiftUI`, `AppKit`) to MacDailyCore.
- Do not write user notes or config without `AtomicWrite`.
- Do not change the daily note filename format without updating `DateFormatting`, tests, and README.
- Do not add heavy dependencies without strong justification — the app values a small footprint.
- Avoid force-unwraps except where the codebase already does (e.g. `AppPaths` directory creation).
- Minimize scope: match existing style, don't refactor unrelated code.

### Appearance and themes

- Editor/preview colors flow from `AppearanceSettings` and `PreviewColorTheme` presets.
- `MacDailyMarkdownTheme` maps element colors to MarkdownUI theme.
- `SplashSyntaxHighlighter` handles preview code-block highlighting.
- `AppearanceFormatting` centralizes editor font, spacing, and color resolution.

### Keyboard shortcuts

- Bindings are stored in `KeyboardShortcuts` / `KeyBinding` (MacDailyCore).
- Menu commands and the editor both respect them via `KeyBinding+AppKit` and `FormattingTextView.performKeyEquivalent`.
- New format actions: add to `MarkdownFormatAction`, implement in `MarkdownFormatting`, wire menu in `MacDailyApp`, and expose in settings.

## Packaging and release

| File | Purpose |
|------|---------|
| `packaging/app.env` | App identity — Makefile, build scripts, and CI source this |
| `packaging/build-app.sh` | Assembles `dist/{APP_BUNDLE_NAME}.app` (release build, icon, ad-hoc sign) |
| `packaging/Info.plist` | Bundle metadata; **version source of truth** (`CFBundleShortVersionString`) |
| `packaging/MacDaily.entitlements` | Sandbox/entitlements for the bundle |
| `packaging/bump-version.sh` | Bumps patch/minor/major in Info.plist |
| `packaging/cask.rb.template` | Homebrew cask template (CI fills version/sha256) |
| `packaging/generate-icon.swift` | Generates AppIcon when Logo.png is missing |
| `.github/workflows/release.yml` | CI: version bump, build, GitHub Release zip, Homebrew tap update |

### Release flow

1. **Patch releases:** merge to `main`; CI auto-bumps if tag `v{version}` already exists.
2. **Minor/major:** run `make bump-version BUMP=minor` (or `major`), commit `packaging/Info.plist`, then merge to `main`.
3. CI skips release on commits whose message starts with `chore: bump version` (avoids double-release).
4. Releases are **ad-hoc signed** — no Apple Developer ID or notarization required.
5. `HOMEBREW_TAP_TOKEN` secret updates the separate `homebrew-tap` repo.

## Dependencies

Declared in `Package.swift` and pinned in `Package.resolved`:

- [MarkdownUI](https://github.com/gonzalezreal/MarkdownUI) (≥ 2.4.0) — markdown preview
- [Splash](https://github.com/JohnSundell/Splash) (≥ 0.16.0) — syntax highlighting

When changing MarkdownUI theme APIs or Splash integration, verify preview rendering in both light and dark modes and with at least one custom `PreviewColorTheme`.

## Common tasks

### Add a new settings field

1. Add property to the relevant model in `MacDailyCore/Models/` (with `Codable` defaults in `init(from:)` if needed).
2. If user-facing, add controls in the appropriate `Views/*SettingsView.swift`.
3. Persist via `AppViewModel` → `ConfigStore.save`.
4. Include in `SettingsExport` if it should survive backup/restore.
5. Add or update a MacDailyCore test if the logic is non-trivial.

### Add a markdown format action

1. `MarkdownFormatAction` — new case + label.
2. `MarkdownFormatting.apply` — toggle/insert logic.
3. `MacDailyApp` Format menu — auto-included via `formattingCases`.
4. `KeyboardShortcuts` — default binding.
5. Test in `MacDailyCoreTests`.

### Change editor behavior

Start in `Sources/MacDaily/Support/MarkdownTextEditor.swift` and `EditorView.swift`. Syntax highlighting for the editor gutter uses `MarkdownEditorHighlighter`; preview uses Splash.

## Git and PR guidelines

- **Do not commit** unless explicitly asked.
- **Do not push** unless explicitly asked.
- Keep changes focused; avoid drive-by refactors.
- Do not commit `.build/`, `dist/`, `.DS_Store`, or release zips (see `.gitignore`).
- Do not commit secrets (`HOMEBREW_TAP_TOKEN`, signing certificates, `.env`).
- Prefer conventional commit prefixes: `feat:`, `fix:`, `chore:`, `docs:`.
- Version bumps: `chore: bump version to X.Y.Z`.

### Before finishing a change

1. Run `make build` for compile errors.
2. Run `make test` when MacDailyCore logic changed.
3. For UI/notification/menu bar changes, note that manual verification requires `make app`.

## Security and privacy

- Notes are **local plain-text files** in a user-selected directory — no cloud sync built in.
- Config is local JSON in Application Support.
- Notification permission is requested for daily reminders only.
- Launch-at-login uses `LaunchAtLoginManager` (SMAppService) — respect user preference flags in `AppConfig`.
- No network calls in the app itself; CI release workflow is the only automated network usage.

## Where to look first

| Task | Start here |
|------|------------|
| App lifecycle, menus | `MacDailyApp.swift` |
| Global app state | `AppViewModel.swift` |
| Note loading/saving | `EditorViewModel.swift`, `NoteStore.swift` |
| Settings persistence | `ConfigStore.swift`, `AppConfig` |
| Daily note filenames | `DateFormatting.swift` |
| Preview appearance | `MacDailyMarkdownTheme.swift`, `PreviewColorTheme.swift` |
| Reminders | `ReminderManager.swift` |
| Menu bar | `StatusBarController.swift`, `MenuBarView.swift` |
| Onboarding | `OnboardingView.swift`, `AppViewModel` onboarding flags |

## Human-facing docs

- **README.md** — install, usage, appearance, shortcuts, release overview (keep in sync when changing user-visible behavior).
- **AGENTS.md** (this file) — agent-oriented build, architecture, and convention details.

When user-visible behavior changes, update README.md. When agent-relevant workflows or architecture change, update this file.
