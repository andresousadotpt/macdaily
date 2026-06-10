# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial open-source documentation: contributing guide, code of conduct, security policy, and issue templates.

## [0.1.0] - 2026-06-10

### Added

- Native macOS app for one markdown note per day (`yyyy-MM-dd.md` in a user-chosen folder).
- Menu bar access with popover editor and full main window.
- Markdown editor with live preview, formatting shortcuts, and syntax-highlighted preview code blocks.
- Customizable appearance: editor zoom, themes, preview presets, line numbers, and sidebar options.
- Daily reminders at configurable local times (packaged `.app` only).
- Settings backup and restore (JSON export/import).
- Launch-at-login preference and onboarding flow.
- Day rollover handling (midnight, wake, foreground).
- Automated releases: GitHub zip, ad-hoc signed `.app`, and Homebrew cask updates.

[Unreleased]: https://github.com/andresousadotpt/macdaily/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/andresousadotpt/macdaily/releases/tag/v0.1.0
