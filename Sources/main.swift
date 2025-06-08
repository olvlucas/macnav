import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var quadrantWindow: QuadrantWindow?
    var toggleEventMonitor: Any?
    var navigationEventMonitor: Any?
    var localEventMonitor: Any?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("macnav application started!")

        // Check for accessibility permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Accessibility permissions are not granted. Please grant them in System Settings -> Privacy & Security -> Accessibility.")
            // Optionally, you could show an alert to the user here.
            // NSApplication.shared.terminate(self) // Or terminate if critical
        }

        setupToggleShortcut()
    }

    func setupToggleShortcut() {
        // Option + Shift + S (KeyCode 1 for S key, with option and shift flags)
        // You can find key codes using various online tools or apps like "Key Codes" on the Mac App Store.
        let mask: NSEvent.ModifierFlags = [.option, .shift]
        let keyCode: UInt16 = 1 // Key code for 'S'

        toggleEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(mask) && event.keyCode == keyCode {
                print("Shortcut pressed!")
                self?.toggleQuadrantWindow()
            }
        }
    }

    func setupNavigationMonitoring() {
        navigationEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let window = self?.quadrantWindow, window.isVisible else { return }

            let keyCode = event.keyCode
            print("Key pressed: \(keyCode)")

            switch keyCode {
            case 13, 4:
                print("Moving up")
                window.moveSelection(direction: .up)
            case 0, 38:
                print("Moving left")
                window.moveSelection(direction: .left)
            case 1, 40:
                print("Moving down")
                window.moveSelection(direction: .down)
            case 2, 37:
                print("Moving right")
                window.moveSelection(direction: .right)
            case 36:
                print("Clicking")
                window.performClickAtSelectedArea()
                self?.hideQuadrantWindow()
            case 53:
                print("Hiding")
                self?.hideQuadrantWindow()
            case 15:
                print("Resetting")
                window.resetToFullScreen()
            default:
                break
            }
        }

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let window = self?.quadrantWindow, window.isVisible else { return event }

            let keyCode = event.keyCode

            switch keyCode {
            case 13, 4, 0, 38, 1, 40, 2, 37, 36, 53, 15:
                return nil
            default:
                return event
            }
        }
    }

    func removeNavigationMonitoring() {
        if let monitor = navigationEventMonitor {
            NSEvent.removeMonitor(monitor)
            navigationEventMonitor = nil
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }

    func toggleQuadrantWindow() {
        if quadrantWindow == nil {
            guard let mainScreen = NSScreen.main else {
                print("Could not get main screen.")
                return
            }
            quadrantWindow = QuadrantWindow(screen: mainScreen)
        }

        if let window = quadrantWindow {
            if window.isVisible {
                hideQuadrantWindow()
            } else {
                showQuadrantWindow()
            }
        }
    }

    func showQuadrantWindow() {
        guard let window = quadrantWindow else { return }

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        setupNavigationMonitoring()
        print("Quadrants shown")
    }

    func hideQuadrantWindow() {
        guard let window = quadrantWindow else { return }
        window.orderOut(nil)
        removeNavigationMonitoring()
        print("Quadrants hidden")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = toggleEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        removeNavigationMonitoring()
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
// Ensure the app runs as an accessory app (no Dock icon or menu bar initially)
// This should be set before NSApplication.shared.run()
// However, for development, it might be easier to see the Dock icon.
// You can enable this for a "release" build.
// NSApp.setActivationPolicy(.accessory)

NSApplication.shared.run()