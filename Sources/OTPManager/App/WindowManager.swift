import Cocoa
import SwiftUI

final class WindowManager {
    static let shared = WindowManager()
    private var openWindows: [String: NSWindow] = [:]

    func openWindow<Content: View>(id: String, title: String, size: NSSize, content: Content) {
        // Bring existing window to front if already open
        if let existingWindow = openWindows[id] {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = title
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.center()

        // Show window in Mission Control (Exposé)
        window.collectionBehavior = [.managed, .participatesInCycle]
        window.contentView = NSHostingView(rootView: content.preferredColorScheme(.dark))

        window.isReleasedWhenClosed = false
        openWindows[id] = window

        // Remove from registry on window close
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.openWindows.removeValue(forKey: id)
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow(id: String) {
        openWindows[id]?.close()
        openWindows.removeValue(forKey: id)
    }
}
