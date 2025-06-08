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
        toggleEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let keyBindingManager = self?.keyBindingManager else { return }

            let startBindings = keyBindingManager.getStartBindings()
            let keyCode = UInt16(event.keyCode)
            let rawFlags = event.modifierFlags.rawValue
            let relevantFlags: UInt = 0x00FF0000
            let maskedFlags = rawFlags & relevantFlags
            let modifiers = NSEvent.ModifierFlags(rawValue: maskedFlags)

            for binding in startBindings {
                if binding.keyCode == keyCode && binding.modifiers == modifiers {
                    print("Start shortcut pressed!")
                    self?.toggleQuadrantWindow()
                    break
                }
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
                      let actions = keyBindingManager.getActions(for: keyCode, modifiers: flags) else {
                    return Unmanaged.passUnretained(event)
                }

                let actionsString = actions.map { $0.rawValue }.joined(separator: ",")
                print("Actions: \(actionsString)")

                for action in actions {
                    switch action {
                    case .up:
                        print("Moving up")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .up)
                        }
                    case .left:
                        print("Moving left")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .left)
                        }
                    case .down:
                        print("Moving down")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .down)
                        }
                    case .right:
                        print("Moving right")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .right)
                        }
                    case .click:
                        print("Clicking")
                        DispatchQueue.main.async {
                            window.performClickAtSelectedArea()
                            appDelegate.hideQuadrantWindow()
                        }
                    case .click1:
                        print("Click 1 (left click)")
                        DispatchQueue.main.async {
                            window.performClickAtCurrentMousePosition(button: .left)
                        }
                    case .click2:
                        print("Click 2 (right click)")
                        DispatchQueue.main.async {
                            window.performClickAtCurrentMousePosition(button: .right)
                        }
                    case .click3:
                        print("Click 3 (middle click)")
                        DispatchQueue.main.async {
                            window.performClickAtCurrentMousePosition(button: .center)
                        }
                    case .end:
                        print("Hiding")
                        DispatchQueue.main.async {
                            appDelegate.hideQuadrantWindow()
                        }
                    case .reset:
                        print("Resetting")
                        DispatchQueue.main.async {
                            window.resetToFullScreen()
                        }
                    case .quit:
                        print("Quitting")
                        DispatchQueue.main.async {
                            NSApplication.shared.terminate(nil)
                        }
                    case .reload:
                        print("Reloading keybindings")
                        DispatchQueue.main.async {
                            appDelegate.keyBindingManager?.reloadBindings()
                        }
                    case .cut_up:
                        print("Cutting up")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .up)
                        }
                    case .cut_down:
                        print("Cutting down")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .down)
                        }
                    case .cut_left:
                        print("Cutting left")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .left)
                        }
                    case .cut_right:
                        print("Cutting right")
                        DispatchQueue.main.async {
                            window.moveSelection(direction: .right)
                        }
                    case .move_up:
                        print("Moving up")
                        DispatchQueue.main.async {
                            window.moveSelectionArea(direction: .up)
                        }
                    case .move_down:
                        print("Moving down")
                        DispatchQueue.main.async {
                            window.moveSelectionArea(direction: .down)
                        }
                    case .move_left:
                        print("Moving left")
                        DispatchQueue.main.async {
                            window.moveSelectionArea(direction: .left)
                        }
                    case .move_right:
                        print("Moving right")
                        DispatchQueue.main.async {
                            window.moveSelectionArea(direction: .right)
                        }
                    case .warp:
                        print("Warping to selected area")
                        DispatchQueue.main.async {
                            window.warpToSelectedArea()
                        }
                    case .start:
                        print("Start action executed")
                        DispatchQueue.main.async {
                            appDelegate.toggleQuadrantWindow()
                        }
                    case .grid, .grid_nav, .history_back, .record, .playback, .windowzoom, .cursorzoom, .ignore:
                        print("Action not implemented yet: \(action.rawValue)")
                    }
                }

                return nil
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