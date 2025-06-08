import Foundation
import AppKit

enum KeynavAction: String, CaseIterable {
    case up = "up"
    case down = "down"
    case left = "left"
    case right = "right"
    case click = "click"
    case end = "end"
    case reset = "reset"
    case cut_up = "cut-up"
    case cut_down = "cut-down"
    case cut_left = "cut-left"
    case cut_right = "cut-right"
    case move_up = "move-up"
    case move_down = "move-down"
    case move_left = "move-left"
    case move_right = "move-right"
    case warp = "warp"
    case grid = "grid"
    case grid_nav = "grid-nav"
    case history_back = "history-back"
    case record = "record"
    case playback = "playback"
    case windowzoom = "windowzoom"
    case cursorzoom = "cursorzoom"
    case ignore = "ignore"
    case quit = "quit"
    case reload = "reload"
}

struct KeyBinding {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
    let action: KeynavAction

    init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags = [], action: KeynavAction) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.action = action
    }
}

class KeyBindingManager {
    private var bindings: [KeyBinding] = []

    init() {
        loadDefaultBindings()
        loadUserBindings()
    }

    private func loadDefaultBindings() {
        bindings = [
            KeyBinding(keyCode: 13, action: .up),       // w
            KeyBinding(keyCode: 4, action: .left),      // h (vim left)
            KeyBinding(keyCode: 0, action: .left),      // a
            KeyBinding(keyCode: 38, action: .down),     // j (vim down)
            KeyBinding(keyCode: 1, action: .down),      // s
            KeyBinding(keyCode: 40, action: .up),       // k (vim up)
            KeyBinding(keyCode: 2, action: .right),     // d
            KeyBinding(keyCode: 37, action: .right),    // l (vim right)
            KeyBinding(keyCode: 36, action: .click),    // Return/Enter
            KeyBinding(keyCode: 53, action: .end),      // Escape
            KeyBinding(keyCode: 15, action: .reset),    // r
            KeyBinding(keyCode: 49, action: .click),    // Space (alternative click)
            KeyBinding(keyCode: 3, action: .end),       // f (alternative end)
            KeyBinding(keyCode: 12, action: .quit),     // q

            KeyBinding(keyCode: 13, modifiers: .shift, action: .move_up),     // Shift+w
            KeyBinding(keyCode: 40, modifiers: .shift, action: .move_up),     // Shift+k
            KeyBinding(keyCode: 0, modifiers: .shift, action: .move_left),    // Shift+a
            KeyBinding(keyCode: 4, modifiers: .shift, action: .move_left),    // Shift+h
            KeyBinding(keyCode: 1, modifiers: .shift, action: .move_down),    // Shift+s
            KeyBinding(keyCode: 38, modifiers: .shift, action: .move_down),   // Shift+j
            KeyBinding(keyCode: 2, modifiers: .shift, action: .move_right),   // Shift+d
            KeyBinding(keyCode: 37, modifiers: .shift, action: .move_right),  // Shift+l

            KeyBinding(keyCode: 13, modifiers: .control, action: .cut_up),    // Ctrl+w
            KeyBinding(keyCode: 40, modifiers: .control, action: .cut_up),    // Ctrl+k
            KeyBinding(keyCode: 0, modifiers: .control, action: .cut_left),   // Ctrl+a
            KeyBinding(keyCode: 4, modifiers: .control, action: .cut_left),   // Ctrl+h
            KeyBinding(keyCode: 1, modifiers: .control, action: .cut_down),   // Ctrl+s
            KeyBinding(keyCode: 38, modifiers: .control, action: .cut_down),  // Ctrl+j
            KeyBinding(keyCode: 2, modifiers: .control, action: .cut_right),  // Ctrl+d
            KeyBinding(keyCode: 37, modifiers: .control, action: .cut_right), // Ctrl+l

            KeyBinding(keyCode: 46, action: .warp),     // m
            KeyBinding(keyCode: 5, action: .grid),      // g
            KeyBinding(keyCode: 35, action: .history_back),  // p
            KeyBinding(keyCode: 14, action: .record),   // e
            KeyBinding(keyCode: 43, action: .windowzoom), // comma
            KeyBinding(keyCode: 47, action: .cursorzoom), // period
            KeyBinding(keyCode: 15, modifiers: [.control, .shift], action: .reload), // Ctrl+Shift+r
        ]
    }

    private func loadUserBindings() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDir.appendingPathComponent(".macnav")

        guard FileManager.default.fileExists(atPath: configPath.path) else {
            print("No .macnav config file found at \(configPath.path)")
            return
        }

        do {
            let content = try String(contentsOf: configPath, encoding: .utf8)
            parseConfigFile(content)
        } catch {
            print("Error reading .macnav file: \(error)")
        }
    }

    private func parseConfigFile(_ content: String) {
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }

            parseBinding(trimmedLine)
        }
    }

    private func parseBinding(_ line: String) {
        let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        guard parts.count >= 2 else {
            print("Invalid binding format: \(line)")
            return
        }

        let keyString = parts[0]
        let actionString = parts[1]

        guard let action = KeynavAction(rawValue: actionString) else {
            print("Unknown action: \(actionString)")
            return
        }

        if let keyBinding = parseKeyString(keyString, action: action) {
            addBinding(keyBinding)
        }
    }

    private func parseKeyString(_ keyString: String, action: KeynavAction) -> KeyBinding? {
        var modifiers: NSEvent.ModifierFlags = []
        var keyPart = keyString

        if keyString.contains("ctrl+") {
            modifiers.insert(.control)
            keyPart = keyPart.replacingOccurrences(of: "ctrl+", with: "")
        }
        if keyString.contains("shift+") {
            modifiers.insert(.shift)
            keyPart = keyPart.replacingOccurrences(of: "shift+", with: "")
        }
        if keyString.contains("alt+") || keyString.contains("option+") {
            modifiers.insert(.option)
            keyPart = keyPart.replacingOccurrences(of: "alt+", with: "")
            keyPart = keyPart.replacingOccurrences(of: "option+", with: "")
        }
        if keyString.contains("cmd+") || keyString.contains("super+") {
            modifiers.insert(.command)
            keyPart = keyPart.replacingOccurrences(of: "cmd+", with: "")
            keyPart = keyPart.replacingOccurrences(of: "super+", with: "")
        }

        guard let keyCode = keyCodeForKey(keyPart) else {
            print("Unknown key: \(keyPart)")
            return nil
        }

        return KeyBinding(keyCode: keyCode, modifiers: modifiers, action: action)
    }

    private func keyCodeForKey(_ key: String) -> UInt16? {
        let keyMap: [String: UInt16] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9,
            "b": 11, "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17, "1": 18, "2": 19,
            "3": 20, "4": 21, "6": 22, "5": 23, "equal": 24, "9": 25, "7": 26, "minus": 27,
            "8": 28, "0": 29, "rightbracket": 30, "o": 31, "u": 32, "leftbracket": 33, "i": 34,
            "p": 35, "return": 36, "l": 37, "j": 38, "quote": 39, "k": 40, "semicolon": 41,
            "backslash": 42, "comma": 43, "slash": 44, "n": 45, "m": 46, "period": 47,
            "tab": 48, "space": 49, "grave": 50, "delete": 51, "enter": 52, "escape": 53,
            "rightcommand": 54, "command": 55, "shift": 56, "capslock": 57, "option": 58,
            "control": 59, "rightshift": 60, "rightoption": 61, "rightcontrol": 62, "function": 63,
            "f17": 64, "keypadperiod": 65, "keypadmultiply": 67, "keypadplus": 69,
            "keypadclear": 71, "keypadenter": 76, "keypaddivide": 75, "keypadminus": 78,
            "keypadequals": 81, "keypad0": 82, "keypad1": 83, "keypad2": 84, "keypad3": 85,
            "keypad4": 86, "keypad5": 87, "keypad6": 88, "keypad7": 89, "keypad8": 91,
            "keypad9": 92, "f5": 96, "f6": 97, "f7": 98, "f3": 99, "f8": 100, "f9": 101,
            "f11": 103, "f13": 105, "f16": 106, "f14": 107, "f10": 109, "f12": 111,
            "f15": 113, "help": 114, "home": 115, "pageup": 116, "forwarddelete": 117,
            "f4": 118, "end": 119, "f2": 120, "pagedown": 121, "f1": 122, "left": 123,
            "right": 124, "down": 125, "up": 126
        ]

        return keyMap[key.lowercased()]
    }

    private func addBinding(_ binding: KeyBinding) {
        bindings.removeAll { $0.keyCode == binding.keyCode && $0.modifiers == binding.modifiers }
        bindings.append(binding)
        print("Added binding: \(binding.keyCode) (\(binding.modifiers.rawValue)) -> \(binding.action.rawValue)")
    }

    func getAction(for keyCode: UInt16, modifiers: NSEvent.ModifierFlags = []) -> KeynavAction? {
        return bindings.first { $0.keyCode == keyCode && $0.modifiers == modifiers }?.action
    }

    func getAllBindings() -> [KeyBinding] {
        return bindings
    }

    func reloadBindings() {
        bindings.removeAll()
        loadDefaultBindings()
        loadUserBindings()
    }
}