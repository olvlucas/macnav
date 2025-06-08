import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var quadrantWindow: QuadrantWindow?
    var eventMonitor: Any?

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

        // Setup the global event monitor for keyboard shortcuts
        // Option + Shift + S (KeyCode 1 for S key, with option and shift flags)
        // You can find key codes using various online tools or apps like "Key Codes" on the Mac App Store.
        let mask: NSEvent.ModifierFlags = [.option, .shift]
        let keyCode: UInt16 = 1 // Key code for 'S'

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(mask) && event.keyCode == keyCode {
                print("Shortcut pressed!")
                self?.toggleQuadrantWindow()
            }
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
                window.orderOut(nil)
                print("Quadrants hidden")
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.preventWindowOrdering()
                print("Quadrants shown")
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
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