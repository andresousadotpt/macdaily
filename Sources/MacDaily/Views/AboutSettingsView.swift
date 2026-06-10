import SwiftUI
import MacDailyCore

struct AboutSettingsView: View {
    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    appIcon
                        .frame(width: 64, height: 64)

                    Text(AppInfo.name)
                        .font(.title2.weight(.semibold))

                    Text("Version \(AppInfo.versionLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("One markdown note per day.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Links") {
                LinkRow(title: "GitHub repository", systemImage: "link", url: AppInfo.repositoryURL)
                LinkRow(title: "Releases", systemImage: "arrow.down.circle", url: AppInfo.releasesURL)
            }

            Section("Details") {
                LabeledContent("Bundle ID") {
                    Text(AppInfo.bundleIdentifier)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Settings file") {
                    Text(AppPaths.configURL.path)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text(AppInfo.copyright)
                    .foregroundStyle(.secondary)
            } footer: {
                Text("Released under the MIT License.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    @ViewBuilder
    private var appIcon: some View {
        if let logo = NSImage(named: "Logo") {
            Image(nsImage: logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
        }
    }
}

private struct LinkRow: View {
    let title: String
    let systemImage: String
    let url: URL

    var body: some View {
        Button {
            AppInfo.open(url)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}
