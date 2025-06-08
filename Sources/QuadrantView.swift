import AppKit

class QuadrantView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height

        // Define colors
        let colors = [
            NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor, // Top-left (Red)
            NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.3).cgColor, // Top-right (Green)
            NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.3).cgColor, // Bottom-left (Blue)
            NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3).cgColor  // Bottom-right (Yellow)
        ]

        let halfWidth = width / 2
        let halfHeight = height / 2

        // Quadrant rects
        let topLeftRect = NSRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
        let topRightRect = NSRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)
        let bottomLeftRect = NSRect(x: 0, y: 0, width: halfWidth, height: halfHeight)
        let bottomRightRect = NSRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight)

        let rects = [topLeftRect, topRightRect, bottomLeftRect, bottomRightRect]

        // Draw quadrants
        for (index, rect) in rects.enumerated() {
            context.setFillColor(colors[index % colors.count])
            context.fill(rect)

            // Optional: Draw borders for clarity
            context.setStrokeColor(NSColor.black.cgColor)
            context.setLineWidth(2)
            context.stroke(rect)
        }
    }

    // Allow clicks to pass through the view if needed (for transparent window)
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil // Pass clicks through
    }
}

class QuadrantWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(contentRect: screen.frame,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        // The screen property is implicitly set by the frame's origin and size relative to the screen coordinates.
        // If specific screen assignment is strictly needed after init, it can be done via setFrame:display:animate:
        // or by ensuring the window is placed onto the correct screen if there are multiple.
        // For a single full-screen window on the main screen, screen.frame is usually sufficient.

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver // Keep it above most other windows
        self.hasShadow = false
        self.ignoresMouseEvents = true // Make window click-through initially

        let quadrantView = QuadrantView(frame: screen.frame)
        self.contentView = quadrantView
    }

    // To make it a proper overlay that doesn't take focus
    override var canBecomeKey: Bool {
        return false
    }

    override var canBecomeMain: Bool {
        return false
    }
}