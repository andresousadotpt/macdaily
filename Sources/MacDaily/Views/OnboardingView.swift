import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var app
    @State private var launchAtLoginEnabled = true

    var body: some View {
        VStack(spacing: 24) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

            VStack(spacing: 8) {
                Text("macdaily")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text("One markdown note for every day")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            if app.needsNotificationSetup {
                notificationStep
            } else if !app.hasNotesFolder {
                folderStep
            } else if app.needsLaunchAtLoginSetup {
                launchAtLoginStep
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .onAppear {
            launchAtLoginEnabled = app.config.launchAtLogin
        }
    }

    private var notificationStep: some View {
        VStack(spacing: 16) {
            Text("macdaily uses notifications for daily writing reminders. Allow notifications to continue.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            switch app.notificationSetup {
            case .loading:
                ProgressView()
            case .needsPermission:
                Button {
                    Task { await app.requestNotificationPermission() }
                } label: {
                    Label("Allow Notifications", systemImage: "bell.badge")
                        .frame(maxWidth: 240)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)

                Button("Continue Without Reminders") {
                    app.continueWithoutReminders()
                }
                .controlSize(.large)
            case .denied:
                VStack(spacing: 12) {
                    Text("Notifications are turned off. Enable them in System Settings to start taking notes.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 420)

                    Button {
                        app.openNotificationSettings()
                    } label: {
                        Label("Open Notification Settings", systemImage: "gear")
                            .frame(maxWidth: 280)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)

                    Button("I've Enabled Notifications") {
                        Task { await app.refreshNotificationSetup() }
                    }

                    Button("Continue Without Reminders") {
                        app.continueWithoutReminders()
                    }
                    .controlSize(.large)
                }
            case .authorized, .unavailable:
                EmptyView()
            }
        }
    }

    private var folderStep: some View {
        VStack(spacing: 16) {
            Text("Choose a folder to store your daily notes. Each day gets its own `.md` file named with the date.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            Button {
                app.chooseNotesFolder()
            } label: {
                Label("Choose Notes Folder", systemImage: "folder")
                    .frame(maxWidth: 240)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
    }

    private var launchAtLoginStep: some View {
        VStack(spacing: 16) {
            Text("Keep macdaily running after you log in so daily notes and reminders stay on schedule.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            Toggle("Open macdaily at login", isOn: $launchAtLoginEnabled)
                .toggleStyle(.switch)
                .frame(maxWidth: 320)

            if !LaunchAtLoginManager.isSupported {
                Text("Launch at login is available in the packaged app (`make app`).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                app.confirmLaunchAtLogin(enabled: launchAtLoginEnabled)
            } label: {
                Label("Continue", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: 240)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
    }
}
