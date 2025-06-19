import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var quadrantWindow: QuadrantWindow?
    var toggleEventMonitor: Any?
    var eventTap: CFMachPort?
    var keyBindingManager: KeyBindingManager?
    var currentQuadrantScreen: NSScreen?
    var lastWarpTime: Date?

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

                appDelegate.executeActionsSequentially(actions, window: window)

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

        func getCurrentScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation

        for screen in NSScreen.screens {
            if screen.frame.contains(mouseLocation) {
                return screen
            }
        }

        return NSScreen.main
    }

    func findMonitorInDirection(_ direction: MovementDirection, from currentScreen: NSScreen) -> NSScreen? {
        let currentFrame = currentScreen.frame
        let screens = NSScreen.screens

        var bestScreen: NSScreen?
        var bestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        for screen in screens {
            guard screen != currentScreen else { continue }

            let screenFrame = screen.frame
            var isInDirection = false
            var distance: CGFloat = 0

            switch direction {
            case .left:
                isInDirection = screenFrame.maxX <= currentFrame.minX
                distance = currentFrame.minX - screenFrame.maxX
            case .right:
                isInDirection = screenFrame.minX >= currentFrame.maxX
                distance = screenFrame.minX - currentFrame.maxX
            case .up:
                isInDirection = screenFrame.minY >= currentFrame.maxY
                distance = screenFrame.minY - currentFrame.maxY
            case .down:
                isInDirection = screenFrame.maxY <= currentFrame.minY
                distance = currentFrame.minY - screenFrame.maxY
            }

            if isInDirection && distance < bestDistance {
                bestDistance = distance
                bestScreen = screen
            }
        }

        return bestScreen
    }

                func switchToMonitor(direction: MovementDirection) {
        // Use the screen where the quadrant window is currently displayed, not mouse location
        guard let currentScreen = currentQuadrantScreen else { return }

        let targetScreen = findMonitorInDirection(direction, from: currentScreen) ?? currentScreen

        if targetScreen != currentScreen {
            // Remove the old event tap first to prevent conflicts
            removeEventTap()

            // Hide the current window
            if let currentWindow = quadrantWindow {
                currentWindow.orderOut(nil)
            }

            // Create new window on target screen and update tracking
            quadrantWindow = QuadrantWindow(screen: targetScreen)
            currentQuadrantScreen = targetScreen
            showQuadrantWindow()
            print("Switched to monitor: \(targetScreen.localizedName)")
        }
    }

    func toggleQuadrantWindow() {
        if let window = quadrantWindow, window.isVisible {
            hideQuadrantWindow()
        } else {
            guard let currentScreen = getCurrentScreen() else {
                print("Could not get current screen.")
                return
            }
            quadrantWindow = QuadrantWindow(screen: currentScreen)
            currentQuadrantScreen = currentScreen
            showQuadrantWindow()
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
        currentQuadrantScreen = nil
        lastWarpTime = nil
        print("Quadrants hidden")
    }

    func shouldDelayAfterWarp() -> Bool {
        guard let lastWarp = lastWarpTime else { return false }
        let timeSinceWarp = Date().timeIntervalSince(lastWarp)
        return timeSinceWarp < 0.1
    }

    func executeActionsSequentially(_ actions: [KeynavAction], window: QuadrantWindow) {
        executeNextAction(actions, index: 0, window: window)
    }

    private func executeNextAction(_ actions: [KeynavAction], index: Int, window: QuadrantWindow) {
        guard index < actions.count else { return }

        let action = actions[index]
        let nextIndex = index + 1

        switch action {
        case .up:
            print("Moving up")
            DispatchQueue.main.async {
                window.moveSelection(direction: .up)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .left:
            print("Moving left")
            DispatchQueue.main.async {
                window.moveSelection(direction: .left)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .down:
            print("Moving down")
            DispatchQueue.main.async {
                window.moveSelection(direction: .down)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .right:
            print("Moving right")
            DispatchQueue.main.async {
                window.moveSelection(direction: .right)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .click:
            print("Clicking")
            DispatchQueue.main.async {
                window.performClickAtSelectedArea()
                self.hideQuadrantWindow()
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .click1:
            print("Click 1 (left click)")
            DispatchQueue.main.async {
                window.performClickAtCurrentMousePosition(button: .left)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .click2:
            print("Click 2 (right click)")
            DispatchQueue.main.async {
                window.performClickAtCurrentMousePosition(button: .right)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .click3:
            print("Click 3 (middle click)")
            DispatchQueue.main.async {
                window.performClickAtCurrentMousePosition(button: .center)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .end:
            print("Hiding")
            DispatchQueue.main.async {
                self.hideQuadrantWindow()
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .reset:
            print("Resetting")
            DispatchQueue.main.async {
                window.resetToFullScreen()
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .quit:
            print("Quitting")
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        case .reload:
            print("Reloading keybindings")
            DispatchQueue.main.async {
                self.keyBindingManager?.reloadBindings()
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .cut_up:
            print("Cutting up")
            DispatchQueue.main.async {
                window.moveSelection(direction: .up)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .cut_down:
            print("Cutting down")
            DispatchQueue.main.async {
                window.moveSelection(direction: .down)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .cut_left:
            print("Cutting left")
            DispatchQueue.main.async {
                window.moveSelection(direction: .left)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .cut_right:
            print("Cutting right")
            DispatchQueue.main.async {
                window.moveSelection(direction: .right)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .move_up:
            print("Moving up")
            DispatchQueue.main.async {
                window.moveSelectionArea(direction: .up)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .move_down:
            print("Moving down")
            DispatchQueue.main.async {
                window.moveSelectionArea(direction: .down)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .move_left:
            print("Moving left")
            DispatchQueue.main.async {
                window.moveSelectionArea(direction: .left)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .move_right:
            print("Moving right")
            DispatchQueue.main.async {
                window.moveSelectionArea(direction: .right)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .warp:
            print("Warping to selected area")
            DispatchQueue.main.async {
                self.lastWarpTime = Date()
                window.warpToSelectedArea()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.executeNextAction(actions, index: nextIndex, window: window)
                }
            }
        case .start:
            print("Start action executed")
            DispatchQueue.main.async {
                self.toggleQuadrantWindow()
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .monitor_left:
            print("Switching to left monitor")
            DispatchQueue.main.async {
                self.switchToMonitor(direction: .left)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .monitor_right:
            print("Switching to right monitor")
            DispatchQueue.main.async {
                self.switchToMonitor(direction: .right)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .monitor_up:
            print("Switching to upper monitor")
            DispatchQueue.main.async {
                self.switchToMonitor(direction: .up)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .monitor_down:
            print("Switching to lower monitor")
            DispatchQueue.main.async {
                self.switchToMonitor(direction: .down)
                self.executeNextAction(actions, index: nextIndex, window: window)
            }
        case .grid, .grid_nav, .history_back, .record, .playback, .windowzoom, .cursorzoom, .ignore:
            print("Action not implemented yet: \(action.rawValue)")
            executeNextAction(actions, index: nextIndex, window: window)
        }
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