//
//  MubTabItemView.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/LYTabView

import Cocoa

class MubTabItemView: NSButton {
    fileprivate let titleView = NSTextField(frame: .zero)
    fileprivate var closeButton: MubHoverButton!

    var tabBarView: MubTabBarView!
    var tabLabelObserver: NSKeyValueObservation?
    var tabViewItem: NSTabViewItem? {
        didSet {
            setupTitleAccordingToItem()
        }
    }

    var drawBorder = false {
        didSet {
            needsDisplay = true
        }
    }

    // hover effect
    private var hovered = false
    private var trackingArea: NSTrackingArea?

    // style
    var xpadding: CGFloat = 4
    var ypadding: CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    var backgroundColor: ColorConfig = [
        .active: NSColor(white: 0.77, alpha: 1),
        .windowInactive: NSColor(white: 0.94, alpha: 1),
        .inactive: NSColor(white: 0.70, alpha: 1)
    ]

    var hoverBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.75, alpha: 1),
        .windowInactive: NSColor(white: 0.94, alpha: 1),
        .inactive: NSColor(white: 0.68, alpha: 1)
    ]

    @objc private dynamic var realBackgroundColor = NSColor(white: 0.73, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }

    var selectedBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.86, alpha: 1),
        .windowInactive: NSColor(white: 0.96, alpha: 1),
        .inactive: NSColor(white: 0.76, alpha: 1)
    ]

    var selectedTextColor: ColorConfig = [
        .active: NSColor.textColor,
        .windowInactive: NSColor(white: 0.4, alpha: 1),
        .inactive: NSColor(white: 0.4, alpha: 1)
    ]

    var unselectedForegroundColor = NSColor(white: 0.4, alpha: 1)
    var closeButtonHoverBackgroundColor = NSColor(white: 0.55, alpha: 0.3)

    override var title: String {
        get {
            return titleView.stringValue
        }
        set(newTitle) {
            titleView.stringValue = newTitle as String
            invalidateIntrinsicContentSize()
        }
    }

    var isMoving = false

    private var shouldDrawInHighLight: Bool {
        if let tabViewItem = tabViewItem {
            return tabViewItem.tabState == .selectedTab && !isDragging
        }
        return false
    }

    private var needAnimation: Bool {
        return self.tabBarView.needAnimation
    }

    override static func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if key == "realBackgroundColor" {
            return CABasicAnimation()
        }
        return super.defaultAnimation(forKey: key) as AnyObject?
    }

    // Drag and Drop
    var dragOffset: CGFloat?
    var isDragging = false
    var draggingView: NSImageView?
    var draggingViewLeadingConstraint: NSLayoutConstraint?

    func setupViews() {
        isBordered = false
        let lowerPriority = NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.defaultLow.rawValue - 10)
        setContentHuggingPriority(lowerPriority, for: .horizontal)

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.isEditable = false
        titleView.alignment = .center
        titleView.isBordered = false
        titleView.drawsBackground = false
        addSubview(titleView)
        let padding = xpadding * 2 + closeButtonSize.width
        titleView.trailingAnchor
            .constraint(greaterThanOrEqualTo: trailingAnchor, constant: -padding).isActive = true
        titleView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: padding).isActive = true
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: ypadding).isActive = true
        titleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -ypadding).isActive = true
        titleView.setContentHuggingPriority(lowerPriority, for: .horizontal)
        titleView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        titleView.lineBreakMode = .byTruncatingTail

        closeButton = MubTabCloseButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.hoverBackgroundColor = closeButtonHoverBackgroundColor
        closeButton.target = self
        closeButton.action = #selector(closeTab)
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize.height).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize.width).isActive = true
        closeButton.isHidden = true
        addSubview(closeButton)
        closeButton.trailingAnchor
            .constraint(greaterThanOrEqualTo: titleView.leadingAnchor, constant: -xpadding).isActive = true
        closeButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: ypadding).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xpadding).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        closeButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -ypadding).isActive = true

        let menu = NSMenu()
        let addMenuItem = NSMenuItem(title: NSLocalizedString("New Tab", comment: "New Tab"),
                                     action: #selector(addNewTab), keyEquivalent: "")
        addMenuItem.target = self
        menu.addItem(addMenuItem)
        let closeMenuItem = NSMenuItem(title: NSLocalizedString("Close Tab", comment: "Close Tab"),
                                       action: #selector(closeTab), keyEquivalent: "")
        closeMenuItem.target = self
        menu.addItem(closeMenuItem)
        let closeOthersMenuItem = NSMenuItem(title: NSLocalizedString("Close other Tabs",
                                                                      comment: "Close other Tabs"),
                                             action: #selector(closeOtherTabs), keyEquivalent: "")
        closeOthersMenuItem.target = self
        menu.addItem(closeOthersMenuItem)

        let closeToRightMenuItem = NSMenuItem(title: "Close Tabs to the Right",
                                              action: #selector(closeToRight),
                                              keyEquivalent: "")
        closeToRightMenuItem.target = self
        menu.addItem(closeToRightMenuItem)

        menu.delegate = self
        self.menu = menu
    }

    func setupTitleAccordingToItem() {
        if let item = tabViewItem {
            tabLabelObserver = item.observe(\.label) { _, _ in
                if let item = self.tabViewItem {
                    self.title = item.label
                }
            }
            title = item.label
        }
    }

    override var intrinsicContentSize: NSSize {
        var size = titleView.intrinsicContentSize
        size.height += ypadding * 2
        if let minHeight = self.tabBarView.minTabHeight, size.height < minHeight {
            size.height = minHeight
        }
        size.width += xpadding * 3 + closeButtonSize.width
        return size
    }

    convenience init(tabViewItem: NSTabViewItem) {
        self.init(frame: .zero)
        self.tabViewItem = tabViewItem
        setupTitleAccordingToItem()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }

    override func draw(_ dirtyRect: NSRect) {
        let status = tabBarView.status
        if shouldDrawInHighLight {
            selectedBackgroundColor[status]!.setFill()
            titleView.textColor = selectedTextColor[status]!
        } else {
            realBackgroundColor.setFill()
            titleView.textColor = unselectedForegroundColor
        }
        bounds.fill()
        if drawBorder {
            let boderFrame = bounds.insetBy(dx: 1, dy: -1)
            tabBarView.borderColor[status]!.setStroke()
            let path = NSBezierPath(rect: boderFrame)
            path.stroke()
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        if let tabViewItem = tabViewItem {
            tabBarView.selectTabViewItem(tabViewItem)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        let status = tabBarView.status
        if !shouldDrawInHighLight {
            animatorOrNot(needAnimation).realBackgroundColor = hoverBackgroundColor[status]!
        }
        closeButton.animatorOrNot(needAnimation).isHidden = false
    }

    override func mouseExited(with theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        let status = tabBarView.status
        if !shouldDrawInHighLight {
            animatorOrNot(needAnimation).realBackgroundColor = backgroundColor[status]!
        }
        closeButton.animatorOrNot(needAnimation).isHidden = true
    }

    override func mouseDragged(with theEvent: NSEvent) {
        if !isDragging {
            setupDragAndDrop(theEvent)
        }
    }

    func updateColors() {
        let status = tabBarView.status
        if hovered {
            realBackgroundColor = hoverBackgroundColor[status]!
        } else {
            realBackgroundColor = backgroundColor[status]!
        }
    }

    override func viewDidMoveToWindow() {
        updateColors()
    }

    @IBAction func addNewTab(_ sender: AnyObject?) {
        if let target = tabBarView.addNewTabButtonTarget, let action = tabBarView.addNewTabButtonAction {
            _ = target.perform(action, with: self)
        }
    }

    @IBAction func closeTab(_ sender: AnyObject?) {
        if let tabViewItem = tabViewItem {
            tabBarView.removeTabViewItem(tabViewItem, animated: true)
        }
    }

    @IBAction func closeOtherTabs(_ send: AnyObject?) {
        if let tabViewItem = tabViewItem {
            tabBarView.removeAllTabViewItemExcept(tabViewItem)
        }
    }

    @IBAction func closeToRight(_ sender: Any) {
        if let tabViewItem = tabViewItem {
            tabBarView.removeFrom(tabViewItem)
        }
    }
}

extension MubTabItemView: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?,
                    item: NSPasteboardItem,
                    provideDataForType type: NSPasteboard.PasteboardType) {}
}

extension MubTabItemView: NSDraggingSource {
    func setupDragAndDrop(_ theEvent: NSEvent) {
        let pasteItem = NSPasteboardItem()
        let dragItem = NSDraggingItem(pasteboardWriter: pasteItem)
        var draggingRect = frame
        draggingRect.size.width = 1
        draggingRect.size.height = 1
        let dummyImage = NSImage(size: NSSize(width: 1, height: 1))
        dragItem.setDraggingFrame(draggingRect, contents: dummyImage)
        let draggingSession = beginDraggingSession(with: [dragItem], event: theEvent, source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
    }

    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation
    {
        if context == .withinApplication {
            return .move
        }
        return NSDragOperation()
    }

    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool {
        return true
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        dragOffset = frame.origin.x - screenPoint.x
        closeButton.isHidden = true
        let dragRect = bounds
        let image = NSImage(data: dataWithPDF(inside: dragRect))
        draggingView = NSImageView(frame: dragRect)
        if let draggingView = draggingView {
            draggingView.image = image
            draggingView.translatesAutoresizingMaskIntoConstraints = false
            tabBarView.addSubview(draggingView)
            draggingView.topAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
            draggingView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor).isActive = true
            draggingViewLeadingConstraint = draggingView.leadingAnchor
                .constraint(equalTo: tabBarView.tabContainerView.leadingAnchor, constant: frame.origin.x)
            draggingViewLeadingConstraint?.isActive = true
        }
        isDragging = true
        titleView.isHidden = true
        needsDisplay = true
    }

    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        if let constraint = draggingViewLeadingConstraint,
           let offset = dragOffset, let draggingView = draggingView
        {
            var constant = screenPoint.x + offset
            let min: CGFloat = 0
            if constant < min {
                constant = min
            }
            let max = tabBarView.tabContainerView.frame.size.width - frame.size.width
            if constant > max {
                constant = max
            }
            constraint.constant = constant

            tabBarView.handleDraggingTab(draggingView.frame, dragTabItemView: self)
        }
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        dragOffset = nil
        isDragging = false
        closeButton.isHidden = false
        titleView.isHidden = false
        draggingView?.removeFromSuperview()
        draggingViewLeadingConstraint = nil
        needsDisplay = true
        if let tabViewItem = tabViewItem {
            tabBarView.updateTabViewForMovedTabItem(tabViewItem)
        }
    }
}

extension MubTabItemView: NSMenuDelegate {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(addNewTab) {
            return (self.tabBarView.addNewTabButtonTarget != nil) && (self.tabBarView.addNewTabButtonAction != nil)
        }
        if menuItem.action == #selector(closeToRight) {
            if let tabItem = self.tabViewItem,
               let tabView = self.tabViewItem?.tabView
            {
                return tabItem != tabView.tabViewItems.last
            }
            return false
        }
        return true
    }
}
