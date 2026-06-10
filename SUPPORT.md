# Support

## Documentation

- [README](README.md) — install, usage, appearance, shortcuts, and releases
- [CONTRIBUTING.md](CONTRIBUTING.md) — development setup and pull request guidelines
- [AGENTS.md](AGENTS.md) — architecture reference for contributors and coding agents

## Getting help

1. Check the [README](README.md) and existing [issues](https://github.com/andresousadotpt/macdaily/issues).
2. Search [closed issues](https://github.com/andresousadotpt/macdaily/issues?q=is%3Aissue+is%3Aclosed) — your question may already be answered.
3. Open a [new issue](https://github.com/andresousadotpt/macdaily/issues/new/choose) with the appropriate template (bug or feature request).

For bugs, include your macOS version, install method, and whether you used `make run` or the packaged app (`make app`).

## Common topics

| Topic | Notes |
| ----- | ----- |
| **Gatekeeper / "app is damaged"** | Expected for Homebrew and GitHub Release builds (ad-hoc signed). Right-click → Open, or build from source with `make app`. |
| **Reminders not firing** | Reminders require the `.app` bundle. Use `make app && open dist/macdaily.app`, not `make run`. |
| **Tests fail to run** | `make test` needs full Xcode installed, not Command Line Tools alone. |
| **Where are my notes?** | Plain `.md` files in the folder you picked at onboarding. Filename format: `2026-06-10.md`. |
| **Where is settings data?** | `~/Library/Application Support/MacDaily/config.json` |

## Security issues

Do not open public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md).

## Feature requests

We welcome ideas. Please use the feature request template and describe the problem you are trying to solve, not only the solution you want.

## No official support SLA

macdaily is an open-source project maintained in spare time. Issues and pull requests are handled as capacity allows. There is no guaranteed response time.
