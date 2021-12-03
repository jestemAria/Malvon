//
//  MubTabBarView.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/LYTabView

import Cocoa

public enum BarStatus {
    case active
    case windowInactive
    case inactive
}

public typealias ColorConfig = [BarStatus: NSColor]

@IBDesignable
public class MubTabBarView: NSView {
    private let serialQueue = DispatchQueue(label: "Operations.TabBarView.UpdaterQueue")
    private var _needsUpdate = false

    @IBOutlet public weak var delegate: NSTabViewDelegate?

    public enum BoderStyle {
        case none
        case top
        case bottom
        case both

        func borderOffset(width: CGFloat = 1) -> CGFloat {
            switch self {
            case .none:
                return 0
            case .top, .bottom:
                return width
            case .both:
                return width * 2
            }
        }

        var alignment: NSLayoutConstraint.Attribute {
            switch self {
            case .none, .both:
                return .centerY
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }
    }

    public var needAnimation: Bool = true
    public var isActive: Bool = true {
        didSet {
            needsDisplay = true
            for view in tabItemViews() {
                view.updateColors()
                view.needsDisplay = true
            }
        }
    }

    public var hideIfOnlyOneTabExists: Bool = true {
        didSet {
            checkVisibilityAccordingToTabCount()
        }
    }

    public var borderStyle: BoderStyle = .none {
        didSet {
            outterStackView.alignment = borderStyle.alignment
            invalidateIntrinsicContentSize()
            needsDisplay = true
            needsLayout = true
        }
    }

    public var paddingWindowButton: Bool = false {
        didSet {
            windowButtonPaddingView.isHidden = !paddingWindowButton
            needsDisplay = true
        }
    }

    public var minTabItemWidth: CGFloat = 100 {
        didSet {
            if let constraint = minViewWidthConstraint {
                constraint.constant = minViewWidth
                needsLayout = true
            }
        }
    }

    public var minTabHeight: CGFloat? {
        didSet {
            resetHeight()
        }
    }

    var status: BarStatus {
        let isWindowActive = self.isWindowActive
        if isActive, isWindowActive {
            return .active
        } else if !isWindowActive {
            return .windowInactive
        } else {
            return .inactive
        }
    }

    public var backgroundColor: ColorConfig = [
        .active: NSColor(white: 0.77, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.70, alpha: 1)
    ]

    public var borderColor: ColorConfig = [
        .active: NSColor(white: 0.72, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.71, alpha: 1)
    ]

    public var selectedBorderColor: ColorConfig = [
        .active: NSColor(white: 0.71, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.71, alpha: 1)
    ]

    public var showAddNewTabButton: Bool = true {
        didSet {
            addTabButton.isHidden = !showAddNewTabButton
            needsUpdate = true
        }
    }

    public weak var addNewTabButtonTarget: AnyObject?

    public var addNewTabButtonAction: Selector?

    public var tabViewItems: [NSTabViewItem] {
        return tabView?.tabViewItems ?? []
    }

    private var packedTabViewItems = [NSTabViewItem]()
    private var lastUnpackedItem: NSTabViewItem {
        return tabViewItems[tabItemViews().count - 1]
    }

    private var hasPackedTabViewItems: Bool {
        return !packedTabViewItems.isEmpty
    }

    private var isWindowActive: Bool {
        if let window = window {
            if (window as? NSPanel) != nil {
                return NSApp.isActive
            } else {
                return window.isKeyWindow || window.isMainWindow
            }
        }
        return false
    }

    @IBOutlet public var tabView: NSTabView? {
        didSet {
            needsUpdate = true
        }
    }

    let tabContainerView = NSStackView(frame: .zero)
    private var buttonHeight: CGFloat {
        if let tabItemView = tabItemViews().first {
            return tabItemView.frame.size.height
        }
        return 20
    }

    private let outterStackView = NSStackView(frame: .zero)
    private var addTabButton: NSButton!
    private var packedTabButton: NSButton!
    private var buttonHeightConstraints = [NSLayoutConstraint]()
    private let windowButtonPaddingView = NSView(frame: .zero)
    private var windowButtonPaddingViewWidthConstraint: NSLayoutConstraint?
    private var minViewWidthConstraint: NSLayoutConstraint?
    private var minViewWidth: CGFloat {
        return minTabItemWidth + 2 * buttonHeight
    }

    override open var intrinsicContentSize: NSSize {
        var height: CGFloat = buttonHeight
        if let aTabView = tabItemViews().first {
            height = aTabView.intrinsicContentSize.height + borderStyle.borderOffset()
        }
        return NSSize(width: NSView.noIntrinsicMetric, height: height)
    }

    private func buildBarButton(image: NSImage?, action: Selector?) -> NSButton {
        let button = NSButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonType(.momentaryChange)
        button.image = image
        button.bezelStyle = .shadowlessSquare
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.target = self
        button.action = action
        let constraint = button.heightAnchor.constraint(equalToConstant: buttonHeight)
        constraint.isActive = true
        buttonHeightConstraints.append(constraint)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }

    private func setupViews() {
        outterStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outterStackView)
        outterStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        outterStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        outterStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        outterStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        outterStackView.orientation = .horizontal
        outterStackView.distribution = .fill
        outterStackView.alignment = borderStyle.alignment
        outterStackView.spacing = 1
        outterStackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        minViewWidthConstraint = outterStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: minViewWidth)
        minViewWidthConstraint?.isActive = true

        tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(tabContainerView, in: .center)
        tabContainerView.orientation = .horizontal
        tabContainerView.distribution = .fillEqually
        tabContainerView.spacing = 1
        tabContainerView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        tabContainerView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .vertical)

        packedTabButton = buildBarButton(image: NSImage(named: NSImage.rightFacingTriangleTemplateName),
                                         action: #selector(showPackedList))
        addTabButton = buildBarButton(image: NSImage(named: NSImage.addTemplateName),
                                      action: #selector(addNewTab))

        outterStackView.addView(packedTabButton, in: .bottom)
        outterStackView.addView(addTabButton, in: .bottom)
        packedTabButton.isHidden = true
        addTabButton.isHidden = !showAddNewTabButton

        windowButtonPaddingView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(windowButtonPaddingView, in: .top)
        windowButtonPaddingViewWidthConstraint = windowButtonPaddingView.widthAnchor.constraint(equalToConstant: 68)
        windowButtonPaddingViewWidthConstraint?.isActive = true
        windowButtonPaddingView.isHidden = !paddingWindowButton

        // Listen to bound changes
        postsBoundsChangedNotifications = true
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(boundDidChangeNotification),
                                               name: NSView.boundsDidChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(boundDidChangeNotification),
                                               name: NSView.frameDidChangeNotification,
                                               object: self)
    }

    override open func viewDidMoveToWindow() {
        if let window = window {
            var width: CGFloat = 68
            if let lastButton = window.standardWindowButton(.zoomButton),
               let firstButton = window.standardWindowButton(.closeButton)
            {
                width = firstButton.frame.origin.x + lastButton.frame.origin.x + lastButton.frame.size.width
            }

            if let constraint = windowButtonPaddingViewWidthConstraint {
                constraint.constant = width
            }
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override public required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func removeTabItemView(tabItemView: MubTabItemView, animated: Bool) {
        tabContainerView.removeView(tabItemView, animated: animated) {
            self.needsUpdate = true
        }
        popFirstPackedItem()
    }

    private func removePackedTabItem(at: Int) {
        packedTabViewItems.remove(at: at)
        if packedTabViewItems.isEmpty {
            packedTabButton.isHidden = true
        }
    }

    public func removeTabViewItem(_ tabviewItem: NSTabViewItem, animated: Bool = false) {
        if let index = packedTabViewItems.firstIndex(of: tabviewItem) {
            removePackedTabItem(at: index)
        }
        tabView?.removeTabViewItem(tabviewItem)
    }

    public func removeAllTabViewItemExcept(_ tabViewItem: NSTabViewItem) {
        for tabItem in tabViewItems where tabItem != tabViewItem {
            self.tabView?.removeTabViewItem(tabItem)
        }
    }

    func removeFrom(_ tabViewItem: NSTabViewItem) {
        if let index = tabViewItems.firstIndex(of: tabViewItem) {
            let dropItems = tabViewItems.dropFirst(index + 1)
            for tabItem in dropItems {
                tabView?.removeTabViewItem(tabItem)
            }
        }
    }

    private func tabItemViews() -> [MubTabItemView] {
        return tabContainerView.views(in: .center).compactMap { $0 as? MubTabItemView }
    }

    private func shouldShowCloseButton(_ tabBarItem: NSTabViewItem) -> Bool {
        return true
    }

    var needsUpdate: Bool {
        get {
            return _needsUpdate
        }
        set(newState) {
            if !newState {
                _needsUpdate = newState
                return
            }
            serialQueue.sync {
                if !self.needsUpdate {
                    self._needsUpdate = true
                    OperationQueue.main.addOperation {
                        self.update()
                    }
                }
            }
        }
    }

    func update() {
        guard needsUpdate else {
            return
        }
        _needsUpdate = false

        if let tabView = tabView {
            let lastTabItem = self.tabItemViews().last?.tabViewItem
            let tabItemViews = self.tabItemViews()
            packedTabViewItems.removeAll()
            for (idx, item) in tabView.tabViewItems.enumerated() {
                if idx < tabItemViews.count {
                    tabItemViews[idx].tabViewItem = item
                } else {
                    insertTabItem(item, index: idx)
                }
            }
            for itemView in self.tabItemViews().dropFirst(tabView.tabViewItems.count) {
                itemView.removeFromSuperview()
            }
            if let lastItem = lastTabItem, self.packedTabViewItems.contains(lastItem) {
                self.tabItemViews().last?.tabViewItem = lastTabItem
            }
            packedTabButton.isHidden = !hasPackedTabViewItems
            checkVisibilityAccordingToTabCount()
            updateTabState()
        }
    }

    func updateTabState() {
        if let item = tabView?.selectedTabViewItem {
            if selectedTabView() == nil {
                tabItemViews().last?.tabViewItem = item
            }
        }
        for v in tabItemViews() {
            v.needsDisplay = true
        }
        needsDisplay = true
    }

    func checkVisibilityAccordingToTabCount() {
        let count = tabViewItems.count
        if hideIfOnlyOneTabExists {
            animatorOrNot().isHidden = count <= 1
        } else {
            animatorOrNot().isHidden = count < 1
        }
    }

    func selectTabViewItem(_ tabViewItem: NSTabViewItem) {
        tabView?.selectTabViewItem(tabViewItem)
    }

    func selectedTabView() -> MubTabItemView? {
        if let selectedTabViewItem = tabView?.selectedTabViewItem {
            for tabView in tabItemViews() where tabView.tabViewItem == selectedTabViewItem {
                return tabView
            }
        }
        return nil
    }

    override open func viewWillMove(toWindow newWindow: NSWindow?) {
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange),
                                               name: NSWindow.didBecomeKeyNotification,
                                               object: newWindow)
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange),
                                               name: NSWindow.didResignKeyNotification,
                                               object: newWindow)
    }

    @objc private func windowStatusDidChange(_ notification: Notification) {
        needsDisplay = true
        tabContainerView.needsDisplay = true
        for itemViews in tabItemViews() {
            itemViews.updateColors()
        }
    }

    override open func draw(_ dirtyRect: NSRect) {
        let status = self.status
        borderColor[status]!.setFill()
        bounds.fill()
        backgroundColor[status]!.setFill()
        for button in [packedTabButton, addTabButton] {
            if let rect = button?.frame {
                rect.fill()
            }
        }

        if paddingWindowButton {
            let paddingRect = NSRect(x: 0, y: 0,
                                     width: windowButtonPaddingView.frame.size.width,
                                     height: frame.size.height)
            NSColor.clear.setFill()
            paddingRect.fill()
        }
    }

    @IBAction public func closeCurrentTab(_ sender: AnyObject?) {
        if let item = tabView?.selectedTabViewItem {
            removeTabViewItem(item, animated: true)
        }
    }

    @objc private func addNewTab(_ sender: AnyObject?) {
        if let action = addNewTabButtonAction {
            DispatchQueue.main.async {
                NSApplication.shared.sendAction(action, to: self.addNewTabButtonTarget, from: self)
            }
        }
    }

    @objc private func selectPackedItem(_ sender: AnyObject) {
        if let item = sender as? NSMenuItem, let tabItem = item.representedObject as? NSTabViewItem {
            tabView?.selectTabViewItem(tabItem)
            item.state = .on
        }
    }

    @objc private func showPackedList(_ sender: AnyObject?) {
        let menu = NSMenu()
        let selectedItem = tabView?.selectedTabViewItem
        var itemsInMenu = [lastUnpackedItem]
        itemsInMenu.append(contentsOf: packedTabViewItems)
        for item in itemsInMenu {
            let menuItem = NSMenuItem(title: item.label, action: nil, keyEquivalent: "")
            if item == selectedItem {
                menuItem.state = .on
            }
            menuItem.representedObject = item
            menuItem.target = self
            menuItem.action = #selector(selectPackedItem)
            menu.addItem(menuItem)
        }
        if let event = window?.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: packedTabButton)
        }
    }

    private func moveTo(_ dragTabItemView: MubTabItemView, position: NSInteger, movingItemView: MubTabItemView) {
        tabContainerView.removeView(dragTabItemView)
        tabContainerView.insertView(dragTabItemView, at: position, in: .center)
        if needAnimation {
            NSAnimationContext.runAnimationGroup({ _ in
                let origFrame = movingItemView.frame
                self.tabContainerView.layoutSubtreeIfNeeded()
                let toFrame = movingItemView.frame
                movingItemView.frame = origFrame
                movingItemView.animator().frame = toFrame
                movingItemView.drawBorder = true
                movingItemView.isMoving = true
            }, completionHandler: {
                movingItemView.isMoving = false
                movingItemView.drawBorder = false
            })
        }
    }

    func handleDraggingTab(_ dragRect: NSRect, dragTabItemView: MubTabItemView) {
        var idx = 0
        var moved = false
        for itemView in tabItemViews() {
            if itemView != dragTabItemView, !itemView.isMoving {
                let midx = itemView.frame.midX
                if midx > dragRect.minX {
                    moveTo(dragTabItemView, position: idx, movingItemView: itemView)
                    moved = true
                    break
                }
                idx += 1
            } else if itemView == dragTabItemView {
                break
            }
        }
        if !moved {
            idx = tabItemViews().count - 1
            for itemView in tabItemViews().reversed() {
                if itemView != dragTabItemView, !itemView.isMoving {
                    let midx = itemView.frame.midX
                    if midx <= dragRect.maxX {
                        moveTo(dragTabItemView, position: idx, movingItemView: itemView)
                        break
                    }
                    idx -= 1
                } else if itemView == dragTabItemView {
                    break
                }
            }
        }
    }

    func updateTabViewForMovedTabItem(_ tabItem: NSTabViewItem) {
        for (idx, itemView) in tabItemViews().enumerated() where itemView.tabViewItem == tabItem {
            self.tabView?.selectTabViewItem(at: 0)
            self.tabView?.removeTabViewItem(tabItem)
            self.tabView?.insertTabViewItem(tabItem, at: idx)
        }
        tabView?.selectTabViewItem(tabItem)
    }

    private func createLYTabItemView(_ item: NSTabViewItem) -> MubTabItemView {
        let tabItemView = MubTabItemView(tabViewItem: item)
        tabItemView.tabBarView = self
        tabItemView.translatesAutoresizingMaskIntoConstraints = false
        tabItemView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        return tabItemView
    }

    private func itemViewForItem(_ item: NSTabViewItem) -> MubTabItemView? {
        for tabItemView in tabItemViews() where tabItemView.tabViewItem == item {
            return tabItemView
        }
        return nil
    }

    public func addTabViewItem(_ item: NSTabViewItem, animated: Bool = false) {
        tabView?.addTabViewItem(item)
        insertTabItem(item, index: tabItemViews().count + packedTabViewItems.count, animated: animated)
    }

    private func resetHeight() {
        if let aTabView = tabItemViews().first {
            let height = aTabView.intrinsicContentSize.height
            for constraint in buttonHeightConstraints {
                constraint.constant = height
            }
        }
    }

    private func needPackItem(addtion: Int = 0) -> Bool {
        let buttonsWidth: CGFloat = (showAddNewTabButton ? 2 : 1) * buttonHeight
        let width = (frame.size.width - buttonsWidth) / CGFloat(tabItemViews().count + addtion)
        return width < minTabItemWidth
    }

    private func packLastTab() {
        guard let lastTabView = tabItemViews().last else {
            return
        }
        insertToPackedItems(lastUnpackedItem, index: 0)
        tabContainerView.removeView(lastTabView)
        updateTabState()
    }

    private func popFirstPackedItem() {
        if let lastTabViewItem = tabItemViews().last?.tabViewItem,
           hasPackedTabViewItems
        {
            let lastUnpackedItem = self.lastUnpackedItem
            let item = packedTabViewItems[0]
            removePackedTabItem(at: 0)
            tabItemViews().last?.tabViewItem = lastUnpackedItem
            insertTabItem(item, index: tabItemViews().count)
            if packedTabViewItems.contains(lastTabViewItem) {
                tabItemViews().last?.tabViewItem = lastTabViewItem
            }
            updateTabState()
        }
    }

    private func insertToPackedItems(_ item: NSTabViewItem, index: NSInteger) {
        packedTabViewItems.insert(item, at: index)
    }

    private func insertTabItem(_ item: NSTabViewItem, index: NSInteger, animated: Bool = false) {
        let needPack = needPackItem(addtion: 1)
        if needPack || (hasPackedTabViewItems && index > tabItemViews().count) {
            packedTabButton.isHidden = false
            if index >= tabItemViews().count {
                insertToPackedItems(item, index: index - tabItemViews().count)
                return
            }
            packLastTab()
        }
        let tabView = createLYTabItemView(item)
        tabContainerView.insertView(tabView,
                                    atIndex: index,
                                    inGravity: .center,
                                    animated: animated,
                                    completionHandler: nil)
        if tabItemViews().count == 1 {
            resetHeight()
        }
    }

    private final func adjustPackedItem() {
        if needPackItem() {
            if tabItemViews().count > 1 {
                packedTabButton.isHidden = false
                packLastTab()
            }
        } else if hasPackedTabViewItems, !needPackItem(addtion: 1) {
            popFirstPackedItem()
        }
    }

    @objc private func boundDidChangeNotification(notification: Notification) {
        guard tabItemViews().last != nil, !tabContainerView.isHidden, tabViewItems.count > 1 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.adjustPackedItem()
        }
    }

    override open func prepareForInterfaceBuilder() {
        var ibTabItem = NSTabViewItem()
        ibTabItem.label = "Tab"
        addTabViewItem(ibTabItem)
        ibTabItem = NSTabViewItem()
        ibTabItem.label = "Bar"
        addTabViewItem(ibTabItem)
    }
}

extension MubTabBarView: NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(_ tabView: NSTabView) {
        needsUpdate = true
        updateTabState()
        delegate?.tabViewDidChangeNumberOfTabViewItems?(tabView)
    }

    public func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        updateTabState()
        delegate?.tabView?(tabView, didSelect: tabViewItem)
    }

    public func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        delegate?.tabView?(tabView, willSelect: tabViewItem)
    }

    public func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let rslt = delegate?.tabView?(tabView, shouldSelect: tabViewItem) {
            return rslt
        }
        return true
    }
}
