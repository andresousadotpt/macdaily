import SwiftUI

struct MainWindowPresenter: ViewModifier {
    @Environment(\.openWindow) private var openWindow

    func body(content: Content) -> some View {
        content
            .onAppear {
                MainWindowOpener.register(openWindow)
            }
            .onReceive(NotificationCenter.default.publisher(for: .openMainWindow)) { _ in
                MainWindowOpener.present(openWindow: openWindow)
            }
    }
}

extension View {
    func presentsMainWindow() -> some View {
        modifier(MainWindowPresenter())
    }
}
