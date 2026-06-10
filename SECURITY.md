# Security policy

## Supported versions

Security fixes are applied to the latest release on `main`. Older releases are not maintained separately.

| Version | Supported |
| ------- | --------- |
| Latest on `main` | Yes |
| Older releases | No |

## Reporting a vulnerability

If you discover a security issue, please report it privately rather than opening a public issue.

**Preferred:** Use [GitHub private vulnerability reporting](https://github.com/andresousadotpt/macdaily/security/advisories/new) if available.

**Alternative:** Contact the maintainer via GitHub ([@andresousadotpt](https://github.com/andresousadotpt)).

Include:

- A description of the vulnerability and its impact
- Steps to reproduce
- macOS version and how you installed macdaily (source build, Homebrew, release zip)
- Any proof-of-concept or suggested fix, if you have one

You should receive an acknowledgment within a reasonable time. We will work with you to understand the issue, develop a fix, and coordinate disclosure.

Please do not disclose the issue publicly until a fix is available, unless we agree otherwise.

## Scope

macdaily is a **local-first** macOS application:

- Daily notes are plain `.md` files in a folder you choose.
- App settings are stored at `~/Library/Application Support/MacDaily/config.json`.
- The app does not perform network requests during normal use.

Reports we are interested in include (but are not limited to):

- Unauthorized access to or corruption of note files or config
- Sandbox or entitlement misconfigurations that expand attack surface
- Unsafe file I/O (e.g. path traversal, symlink issues, non-atomic writes)
- Privilege escalation via launch-at-login or notification handlers
- Supply-chain issues in the build or release pipeline

Out of scope for this project:

- Social engineering or physical access to an unlocked Mac
- Issues in third-party dependencies unless they affect macdaily in a exploitable way (still report — we may upstream or pin versions)
- Gatekeeper warnings for ad-hoc signed release builds (expected; build from source to avoid)

## Safe defaults

- Do not commit secrets, tokens, or signing certificates.
- CI uses repository secrets only for automated Homebrew tap updates (`HOMEBREW_TAP_TOKEN`).
- User notes and settings are never uploaded by the app.

Thank you for helping keep macdaily and its users safe.
