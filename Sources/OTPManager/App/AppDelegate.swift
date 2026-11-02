import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var storageManager = StorageManager()
    var localEventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set application icon from ICNS resource
        if let iconPath = Bundle.module.path(forResource: "AppIcon", ofType: "icns"),
           let appIcon = NSImage(contentsOfFile: iconPath) {
            NSApplication.shared.applicationIconImage = appIcon
        }

        // Hide the application icon from the Dock
        NSApp.setActivationPolicy(.accessory)

        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "OTP Manager")
            button.target = self
            button.action = #selector(handleStatusItemClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let mainView = MainView()
            .environmentObject(storageManager)
            .preferredColorScheme(.dark)

        popover.contentSize = NSSize(width: 340, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: mainView)

        // Global hotkey trigger action
        HotKeyManager.shared.onTrigger = { [weak self] in
            DispatchQueue.main.async {
                self?.togglePopover()
            }
        }
        HotKeyManager.shared.register()

        // Esc hides the main menu popover or closes the active key window
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // KeyCode 53 = Escape
                if self?.popover.isShown == true {
                    self?.closePopover()
                    return nil
                }

                if let keyWindow = NSApp.keyWindow {
                    keyWindow.close()
                    return nil
                }
            }
            return event
        }
    }

    @objc func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            if popover.isShown {
                closePopover()
            }
            showContextMenu(sender)
        } else {
            togglePopover()
        }
    }

    private func showContextMenu(_ button: NSStatusBarButton) {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit OTPManager", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        button.performClick(nil)
        statusItem?.menu = nil
    }

    @objc func openSettings() {
        WindowManager.shared.openWindow(
            id: "settings",
            title: "Settings",
            size: NSSize(width: 320, height: 180),
            content: SettingsView()
        )
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        if let button = statusItem?.button {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func closePopover() {
        popover.performClose(nil)
    }
}
