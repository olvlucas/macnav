import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var quadrantWindow: QuadrantWindow?
    var toggleEventMonitor: Any?
    var eventTap: CFMachPort?
    var keyBindingManager: KeyBindingManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("macnav application started!")

        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Accessibility permissions are not granted. Please grant them in System Settings -> Privacy & Security -> Accessibility.")
        }

        keyBindingManager = KeyBindingManager()
        setupToggleShortcut()
    }

    func setupToggleShortcut() {
        let mask: NSEvent.ModifierFlags = [.option, .shift]
        let keyCode: UInt16 = 1

        toggleEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(mask) && event.keyCode == keyCode {
                print("Shortcut pressed!")
                self?.toggleQuadrantWindow()
            }
        }
    }

    func setupEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon!).takeUnretainedValue() as AppDelegate?,
                      let window = appDelegate.quadrantWindow,
                      window.isVisible else {
                    return Unmanaged.passUnretained(event)
                }

                let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                let rawFlags = event.flags.rawValue
                let relevantFlags: UInt64 = 0x00FF0000
                let maskedFlags = rawFlags & relevantFlags
                let flags = NSEvent.ModifierFlags(rawValue: UInt(maskedFlags))
                print("Intercepted key: \(keyCode) with modifiers: \(flags)")

                guard let keyBindingManager = appDelegate.keyBindingManager,
                      let action = keyBindingManager.getAction(for: keyCode, modifiers: flags) else {
                    return Unmanaged.passUnretained(event)
                }

                print("Action: \(action.rawValue)")

                switch action {
                case .up:
                    print("Moving up")
                    DispatchQueue.main.async {
                        window.moveSelection(direction: .up)
                    }
                    return nil
                case .left:
                    print("Moving left")
                    DispatchQueue.main.async {
                        window.moveSelection(direction: .left)
                    }
                    return nil
                case .down:
                    print("Moving down")
                    DispatchQueue.main.async {
                        window.moveSelection(direction: .down)
                    }
                    return nil
                case .right:
                    print("Moving right")
                    DispatchQueue.main.async {
                        window.moveSelection(direction: .right)
                    }
                    return nil
                case .click:
                    print("Clicking")
                    DispatchQueue.main.async {
                        window.performClickAtSelectedArea()
                        appDelegate.hideQuadrantWindow()
                    }
                    return nil
                case .end:
                    print("Hiding")
                    DispatchQueue.main.async {
                        appDelegate.hideQuadrantWindow()
                    }
                    return nil
                case .reset:
                    print("Resetting")
                    DispatchQueue.main.async {
                        window.resetToFullScreen()
                    }
                    return nil
                case .quit:
                    print("Quitting")
                    DispatchQueue.main.async {
                        NSApplication.shared.terminate(nil)
                    }
                    return nil
                case .reload:
                    print("Reloading keybindings")
                    DispatchQueue.main.async {
                        appDelegate.keyBindingManager?.reloadBindings()
                    }
                    return nil
                case .cut_up, .cut_down, .cut_left, .cut_right:
                    print("Cut action: \(action.rawValue)")
                    return nil
                case .warp, .grid, .grid_nav, .history_back, .record, .playback, .windowzoom, .cursorzoom, .ignore:
                    print("Action not implemented yet: \(action.rawValue)")
                    return nil
                }
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("Event tap created and enabled")
        } else {
            print("Failed to create event tap")
        }
    }

    func removeEventTap() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
            print("Event tap disabled and removed")
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

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        setupEventTap()
        print("Quadrants shown")
    }

    func hideQuadrantWindow() {
        guard let window = quadrantWindow else { return }
        window.orderOut(nil)
        removeEventTap()
        print("Quadrants hidden")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = toggleEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        removeEventTap()
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

NSApplication.shared.run()