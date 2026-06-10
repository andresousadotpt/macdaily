# Contributing to macdaily

Thank you for your interest in contributing. macdaily is a native macOS app for writing one markdown note per day. This guide covers how to get set up, propose changes, and what we expect in pull requests.

## Before you start

- Read the [README](README.md) for install and usage.
- Browse [open issues](https://github.com/andresousadotpt/macdaily/issues) and [pull requests](https://github.com/andresousadotpt/macdaily/pulls) to avoid duplicate work.
- For larger changes, open an issue first to discuss the approach.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode Command Line Tools (`xcode-select --install`)
- Full **Xcode** (not Command Line Tools alone) to run `make test`

## Getting started

```bash
git clone https://github.com/andresousadotpt/macdaily.git
cd macdaily
make build
make run      # debug launch (reminders skipped)
make test     # unit tests
make app      # release .app in ./dist/ — use for manual QA (reminders, menu bar)
```

## Project layout

| Target | Purpose |
| ------ | ------- |
| **MacDailyCore** | Models, persistence, pure logic — no UI imports |
| **MacDaily** | SwiftUI views, AppKit bridges, menu bar, notifications |

- New models/settings → `Sources/MacDailyCore/Models/`
- File I/O and config → `Sources/MacDailyCore/Services/` or `Utilities/`
- UI screens → `Sources/MacDaily/Views/`
- AppKit bridges → `Sources/MacDaily/Support/`

AI coding agents can read [AGENTS.md](AGENTS.md) for deeper architecture and convention details.

## How to contribute

### Reporting bugs

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md). Include:

- macOS version
- How you installed (build from source, Homebrew, GitHub Release)
- Steps to reproduce and expected vs actual behavior
- Whether you used `make run` or the packaged `.app` (some features, like reminders, only work in the bundle)

### Suggesting features

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md). Describe the problem, your proposed solution, and any alternatives you considered.

### Pull requests

1. Fork the repo and create a branch from `main`.
2. Make focused changes — one logical change per PR when possible.
3. Run `make build` before opening the PR.
4. Run `make test` when you change **MacDailyCore** logic.
5. For UI, menu bar, or notification changes, note manual QA steps (`make app` → `open dist/macdaily.app`).
6. Open a PR against `main` and fill out the [pull request template](.github/pull_request_template.md).

### Commit messages

Use conventional prefixes when they fit:

- `feat:` — new user-facing behavior
- `fix:` — bug fix
- `docs:` — documentation only
- `chore:` — tooling, CI, version bumps
- `test:` — tests only

Example: `fix: preserve cursor position after bold toggle`

## Code guidelines

- **MacDailyCore** must not import SwiftUI or AppKit.
- Persist config via `ConfigStore`; write note files through `NoteStore` and `AtomicWrite` only.
- Daily note filenames stay `yyyy-MM-dd.md` — changes require updates to `DateFormatting`, tests, and docs.
- Match existing naming, structure, and patterns in the file you are editing.
- Avoid drive-by refactors unrelated to your change.
- Do not commit `.build/`, `dist/`, `.DS_Store`, or release artifacts.

### Testing

Tests live in `Tests/MacDailyCoreTests/` and target **MacDailyCore** only. Prefer deterministic dates and temporary directories for file I/O tests.

```bash
make test
# or focus one test:
swift test --filter MacDailyCoreTests.testFilenameUsesIsoDate
```

UI and AppKit behavior is validated manually via `make app`.

## Releases

Maintainers handle releases through CI on push to `main`. See [README — Releasing](README.md#releasing). Contributors do not need to bump versions unless asked.

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

## Questions

Open a [GitHub Discussion](https://github.com/andresousadotpt/macdaily/discussions) or issue if Discussions are not enabled, or see [SUPPORT.md](SUPPORT.md).
