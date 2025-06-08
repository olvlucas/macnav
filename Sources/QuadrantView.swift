import AppKit

struct QuadrantArea {
    let rect: NSRect
    let level: Int

    func subdivided() -> [QuadrantArea] {
        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2

        return [
            QuadrantArea(rect: NSRect(x: rect.minX, y: rect.minY + halfHeight, width: halfWidth, height: halfHeight), level: level + 1),
            QuadrantArea(rect: NSRect(x: rect.minX + halfWidth, y: rect.minY + halfHeight, width: halfWidth, height: halfHeight), level: level + 1),
            QuadrantArea(rect: NSRect(x: rect.minX, y: rect.minY, width: halfWidth, height: halfHeight), level: level + 1),
            QuadrantArea(rect: NSRect(x: rect.minX + halfWidth, y: rect.minY, width: halfWidth, height: halfHeight), level: level + 1)
        ]
    }
}

class QuadrantView: NSView {
    private var currentArea: NSRect = NSRect.zero

    override func awakeFromNib() {
        super.awakeFromNib()
        resetToFullScreen()
    }

    func resetToFullScreen() {
        currentArea = self.bounds
        needsDisplay = true
    }

    func moveSelection(direction: MovementDirection) {
        switch direction {
        case .up:
            let newHeight = currentArea.height / 2
            currentArea = NSRect(
                x: currentArea.minX,
                y: currentArea.minY + newHeight,
                width: currentArea.width,
                height: newHeight
            )
        case .down:
            let newHeight = currentArea.height / 2
            currentArea = NSRect(
                x: currentArea.minX,
                y: currentArea.minY,
                width: currentArea.width,
                height: newHeight
            )
        case .left:
            let newWidth = currentArea.width / 2
            currentArea = NSRect(
                x: currentArea.minX,
                y: currentArea.minY,
                width: newWidth,
                height: currentArea.height
            )
        case .right:
            let newWidth = currentArea.width / 2
            currentArea = NSRect(
                x: currentArea.minX + newWidth,
                y: currentArea.minY,
                width: newWidth,
                height: currentArea.height
            )
        }
        needsDisplay = true
    }

    func getCurrentSelectedRect() -> NSRect {
        return currentArea
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let dimmedColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor
        let lineColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.9).cgColor
        let centerColor = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.9).cgColor

        context.setFillColor(dimmedColor)
        context.fill(self.bounds)

        context.setStrokeColor(lineColor)
        context.setLineWidth(2)

        let centerX = currentArea.midX
        let centerY = currentArea.midY

        context.move(to: CGPoint(x: centerX, y: 0))
        context.addLine(to: CGPoint(x: centerX, y: self.bounds.height))
        context.strokePath()

        context.move(to: CGPoint(x: 0, y: centerY))
        context.addLine(to: CGPoint(x: self.bounds.width, y: centerY))
        context.strokePath()

        context.setStrokeColor(lineColor)
        context.setLineWidth(3)
        context.stroke(currentArea)

        let centerRadius: CGFloat = 8
        let centerRect = NSRect(
            x: centerX - centerRadius/2,
            y: centerY - centerRadius/2,
            width: centerRadius,
            height: centerRadius
        )

        context.setFillColor(centerColor)
        context.fillEllipse(in: centerRect)
        context.setStrokeColor(lineColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: centerRect)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

enum MovementDirection {
    case up, down, left, right
}

class QuadrantWindow: NSWindow {
    private var quadrantView: QuadrantView!

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.hasShadow = false
        self.ignoresMouseEvents = true

        quadrantView = QuadrantView(frame: screen.frame)
        self.contentView = quadrantView
    }

    func moveSelection(direction: MovementDirection) {
        quadrantView.moveSelection(direction: direction)
    }

    func resetToFullScreen() {
        quadrantView.resetToFullScreen()
    }

    func performClickAtSelectedArea() {
        let selectedRect = quadrantView.getCurrentSelectedRect()
        let centerPoint = NSPoint(x: selectedRect.midX, y: selectedRect.midY)

        let screenPoint = self.convertPoint(toScreen: centerPoint)

        let clickEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: CGPoint(x: screenPoint.x, y: screenPoint.y), mouseButton: .left)
        let releaseEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: CGPoint(x: screenPoint.x, y: screenPoint.y), mouseButton: .left)

        clickEvent?.post(tap: .cghidEventTap)
        releaseEvent?.post(tap: .cghidEventTap)
    }

    override func makeKeyAndOrderFront(_ sender: Any?) {
        super.makeKeyAndOrderFront(sender)
        quadrantView.resetToFullScreen()
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}