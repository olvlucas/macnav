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
    private var cursorZoomMode: Bool = false
    private var cursorZoomArea: NSRect = NSRect.zero

    override func awakeFromNib() {
        super.awakeFromNib()
        resetToFullScreen()
    }

    func resetToFullScreen() {
        currentArea = self.bounds
        cursorZoomMode = false
        cursorZoomArea = NSRect.zero
        setNeedsDisplay(self.bounds)
    }

    func setupCursorZoom(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        cursorZoomMode = true

        let halfWidth = width / 2
        let halfHeight = height / 2

        var zoomX = centerX - halfWidth
        var zoomY = centerY - halfHeight

        zoomX = max(0, min(zoomX, self.bounds.width - width))
        zoomY = max(0, min(zoomY, self.bounds.height - height))

        cursorZoomArea = NSRect(x: zoomX, y: zoomY, width: width, height: height)
        currentArea = cursorZoomArea

        print("QuadrantView bounds: \(self.bounds)")
        print("Cursor zoom area: \(cursorZoomArea)")

        setNeedsDisplay(self.bounds)
    }

    func moveSelection(direction: MovementDirection) {
        if cursorZoomMode {
            let boundingArea = cursorZoomArea
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
        } else {
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
        }
        setNeedsDisplay(self.bounds)
    }

    func moveSelectionArea(direction: MovementDirection) {
        let moveDistance = min(currentArea.width * 0.1, currentArea.height * 0.1)
        let bounds = cursorZoomMode ? cursorZoomArea : self.bounds

        switch direction {
        case .up:
            let newY = min(currentArea.minY + moveDistance, bounds.maxY - currentArea.height)
            currentArea = NSRect(
                x: currentArea.minX,
                y: newY,
                width: currentArea.width,
                height: currentArea.height
            )
        case .down:
            let newY = max(currentArea.minY - moveDistance, bounds.minY)
            currentArea = NSRect(
                x: currentArea.minX,
                y: newY,
                width: currentArea.width,
                height: currentArea.height
            )
        case .left:
            let newX = max(currentArea.minX - moveDistance, bounds.minX)
            currentArea = NSRect(
                x: newX,
                y: currentArea.minY,
                width: currentArea.width,
                height: currentArea.height
            )
        case .right:
            let newX = min(currentArea.minX + moveDistance, bounds.maxX - currentArea.width)
            currentArea = NSRect(
                x: newX,
                y: currentArea.minY,
                width: currentArea.width,
                height: currentArea.height
            )
        }
        setNeedsDisplay(self.bounds)
    }

    func getCurrentSelectedRect() -> NSRect {
        return currentArea
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.clear(self.bounds)

        let dimmedColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor
        let lineColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.9).cgColor
        let centerColor = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.9).cgColor

        context.setFillColor(dimmedColor)
        context.fill(self.bounds)

        if cursorZoomMode {
            let zoomBorderColor = NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.8).cgColor
            context.setStrokeColor(zoomBorderColor)
            context.setLineWidth(4)
            context.stroke(cursorZoomArea)

            let zoomFillColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1).cgColor
            context.setFillColor(zoomFillColor)
            context.fill(cursorZoomArea)
        }

        context.setStrokeColor(lineColor)
        context.setLineWidth(2)

        let centerX = currentArea.midX
        let centerY = currentArea.midY

        let drawBounds = cursorZoomMode ? cursorZoomArea : self.bounds

        context.move(to: CGPoint(x: centerX, y: drawBounds.minY))
        context.addLine(to: CGPoint(x: centerX, y: drawBounds.maxY))
        context.strokePath()

        context.move(to: CGPoint(x: drawBounds.minX, y: centerY))
        context.addLine(to: CGPoint(x: drawBounds.maxX, y: centerY))
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
    private var lastClickTime: Date?
    private var lastClickPosition: CGPoint?
    private var lastClickButton: CGMouseButton?
    private var clickCount: Int = 0

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

    func moveSelectionArea(direction: MovementDirection) {
        quadrantView.moveSelectionArea(direction: direction)
    }

    func resetToFullScreen() {
        quadrantView.resetToFullScreen()
    }

    func setupCursorZoom(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        guard let screen = self.screen else { return }

        let windowFrame = self.frame
        let screenFrame = screen.frame

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? screenFrame.height
        let flippedY = globalScreenHeight - centerY

        let relativeX = centerX - windowFrame.minX
        let relativeY = windowFrame.maxY - flippedY

        print("Mouse location: \(centerX), \(centerY)")
        print("Window frame: \(windowFrame)")
        print("Screen frame: \(screenFrame)")
        print("Relative position: \(relativeX), \(relativeY)")

        quadrantView.setupCursorZoom(centerX: relativeX, centerY: relativeY, width: width, height: height)
    }

    func performClickAtSelectedArea() {
        let selectedRect = quadrantView.getCurrentSelectedRect()
        let centerPoint = NSPoint(x: selectedRect.midX, y: selectedRect.midY)

        print("Selected rect: \(selectedRect)")
        print("Center point (window coords): \(centerPoint)")

        guard let currentScreen = self.screen else {
            print("Could not get current screen for clicking")
            return
        }

        let windowOrigin = self.frame.origin
        let screenPoint = NSPoint(
            x: windowOrigin.x + centerPoint.x,
            y: windowOrigin.y + centerPoint.y
        )

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? currentScreen.frame.height
        let flippedScreenPoint = CGPoint(
            x: screenPoint.x,
            y: globalScreenHeight - screenPoint.y
        )

        print("Window origin: \(windowOrigin)")
        print("Screen point: \(screenPoint)")
        print("Global screen height: \(globalScreenHeight)")
        print("Flipped screen point: \(flippedScreenPoint)")

        let clickEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: flippedScreenPoint, mouseButton: .left)
        let releaseEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: flippedScreenPoint, mouseButton: .left)

        if let click = clickEvent, let release = releaseEvent {
            click.post(tap: CGEventTapLocation.cghidEventTap)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                release.post(tap: CGEventTapLocation.cghidEventTap)
            }
            print("Click events posted")
        } else {
            print("Failed to create click events")
        }
    }

        func performClickAtCurrentMousePosition(button: CGMouseButton) {
        let currentMouseLocation = NSEvent.mouseLocation

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? (NSScreen.main?.frame.height ?? 0)
        let flippedScreenPoint = CGPoint(
            x: currentMouseLocation.x,
            y: globalScreenHeight - currentMouseLocation.y
        )

        print("Current mouse location: \(currentMouseLocation)")
        print("Global screen height: \(globalScreenHeight)")
        print("Flipped screen point: \(flippedScreenPoint)")

                let maxClickDistance: CGFloat = 6.0

        if let lastPos = lastClickPosition,
           let lastBtn = lastClickButton,
           lastBtn == button {

            let distance = sqrt(pow(flippedScreenPoint.x - lastPos.x, 2) + pow(flippedScreenPoint.y - lastPos.y, 2))

            if distance <= maxClickDistance {
                self.clickCount = self.clickCount + 1
            } else {
                self.clickCount = 1
            }
        } else {
            self.clickCount = 1
        }

        let (downEventType, upEventType): (CGEventType, CGEventType)
        switch button {
        case .left:
            downEventType = .leftMouseDown
            upEventType = .leftMouseUp
        case .right:
            downEventType = .rightMouseDown
            upEventType = .rightMouseUp
        case .center:
            downEventType = .otherMouseDown
            upEventType = .otherMouseUp
        @unknown default:
            downEventType = .leftMouseDown
            upEventType = .leftMouseUp
        }

        let clickEvent = CGEvent(mouseEventSource: nil, mouseType: downEventType, mouseCursorPosition: flippedScreenPoint, mouseButton: button)
        let releaseEvent = CGEvent(mouseEventSource: nil, mouseType: upEventType, mouseCursorPosition: flippedScreenPoint, mouseButton: button)

        if let click = clickEvent, let release = releaseEvent {
            click.setIntegerValueField(.mouseEventClickState, value: Int64(self.clickCount))
            click.post(tap: CGEventTapLocation.cghidEventTap)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                release.setIntegerValueField(.mouseEventClickState, value: Int64(self.clickCount))
                release.post(tap: CGEventTapLocation.cghidEventTap)
            }
            print("Click events posted (count: \(self.clickCount)) at current mouse position")
        } else {
            print("Failed to create click events")
        }

        lastClickTime = Date()
        lastClickPosition = flippedScreenPoint
        lastClickButton = button
    }

    func warpToSelectedArea() {
        let selectedRect = quadrantView.getCurrentSelectedRect()
        let centerPoint = NSPoint(x: selectedRect.midX, y: selectedRect.midY)

        print("Selected rect: \(selectedRect)")
        print("Center point (window coords): \(centerPoint)")

        guard let currentScreen = self.screen else {
            print("Could not get current screen for warping")
            return
        }

        let windowOrigin = self.frame.origin
        let screenPoint = NSPoint(
            x: windowOrigin.x + centerPoint.x,
            y: windowOrigin.y + centerPoint.y
        )

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? currentScreen.frame.height
        let flippedScreenPoint = CGPoint(
            x: screenPoint.x,
            y: globalScreenHeight - screenPoint.y
        )

        print("Window origin: \(windowOrigin)")
        print("Screen point: \(screenPoint)")
        print("Global screen height: \(globalScreenHeight)")
        print("Flipped screen point: \(flippedScreenPoint)")

        let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: flippedScreenPoint, mouseButton: .left)

        if let move = moveEvent {
            move.post(tap: CGEventTapLocation.cghidEventTap)
            print("Mouse warped to selected area")
        } else {
            print("Failed to create mouse move event")
        }
    }

    override func makeKeyAndOrderFront(_ sender: Any?) {
        super.makeKeyAndOrderFront(sender)
        quadrantView.resetToFullScreen()
        resetClickTracking()
    }

    func resetClickTracking() {
        lastClickTime = nil
        lastClickPosition = nil
        lastClickButton = nil
        clickCount = 0
    }

    func performScrollUp() {
        let currentMouseLocation = NSEvent.mouseLocation

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? (NSScreen.main?.frame.height ?? 0)
        let flippedScreenPoint = CGPoint(
            x: currentMouseLocation.x,
            y: globalScreenHeight - currentMouseLocation.y
        )

        print("Scroll up at mouse location: \(currentMouseLocation)")
        print("Flipped screen point: \(flippedScreenPoint)")

        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: 10, wheel2: 0, wheel3: 0)

        if let scroll = scrollEvent {
            scroll.location = flippedScreenPoint
            scroll.post(tap: CGEventTapLocation.cghidEventTap)
            print("Scroll up event posted")
        } else {
            print("Failed to create scroll up event")
        }
    }

    func performScrollDown() {
        let currentMouseLocation = NSEvent.mouseLocation

        let globalScreenHeight = NSScreen.screens.map { $0.frame.maxY }.max() ?? (NSScreen.main?.frame.height ?? 0)
        let flippedScreenPoint = CGPoint(
            x: currentMouseLocation.x,
            y: globalScreenHeight - currentMouseLocation.y
        )

        print("Scroll down at mouse location: \(currentMouseLocation)")
        print("Flipped screen point: \(flippedScreenPoint)")

        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: -10, wheel2: 0, wheel3: 0)

        if let scroll = scrollEvent {
            scroll.location = flippedScreenPoint
            scroll.post(tap: CGEventTapLocation.cghidEventTap)
            print("Scroll down event posted")
        } else {
            print("Failed to create scroll down event")
        }
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}