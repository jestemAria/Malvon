//
//  MATabBarItem.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

@objc public protocol MATabBarItemDelegate: NSObjectProtocol {
    @objc optional func tabBarItem(_ tabBarItem: MATabBarItem, wantsToClose tab: MATab)
}

open class MATabBarItem: NSButton {
    open var tab: MATab
    var isSelectedTab = false
    open weak var delegate: MATabBarItemDelegate?
    open var configuration = MATabViewConfiguration()

    let tabTitle = NSTextField(frame: .zero)
    open var closeButton = NSButton(frame: .zero)

    var xPosition: CGFloat = 4
    var yPosition: CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)

    /// The Tab Title
    open var label: String {
        get {
            return tabTitle.stringValue
        }
        set(title) {
            tabTitle.stringValue = title as String
        }
    }

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        var bgColor: NSColor = configuration.lightTabColor
        layer?.borderColor = configuration.lightTabBorderColor.cgColor
        layer?.cornerRadius = 4
        layer?.borderWidth = 1
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"

        if appearance == "Dark" {
            bgColor = configuration.darkTabColor
            layer?.borderColor = configuration.darkTabBorderColor.cgColor
        }

        layer?.masksToBounds = true
        layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        dirtyRect.fill()
    }

    private final func configureViews() {
        // Tab Title
        let position = xPosition * 2 + closeButtonSize.width

        tabTitle.translatesAutoresizingMaskIntoConstraints = false
        tabTitle.isEditable = false
        tabTitle.alignment = .center
        tabTitle.isBordered = false
        tabTitle.drawsBackground = false
        addSubview(tabTitle)
        tabTitle.trailingAnchor
            .constraint(greaterThanOrEqualTo: trailingAnchor, constant: -position).isActive = true
        tabTitle.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: position).isActive = true
        tabTitle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tabTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tabTitle.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: yPosition).isActive = true
        tabTitle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -yPosition).isActive = true
        tabTitle.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.defaultLow.rawValue - 10), for: .horizontal)
        tabTitle.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        tabTitle.lineBreakMode = .byTruncatingTail

        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = self
        closeButton.action = #selector(closeTab)
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize.height).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize.width).isActive = true
        addSubview(closeButton)
        closeButton.trailingAnchor
            .constraint(greaterThanOrEqualTo: tabTitle.leadingAnchor, constant: -xPosition).isActive = true
        closeButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: yPosition).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xPosition).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        closeButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -yPosition).isActive = true
        closeButton.bezelStyle = .shadowlessSquare
        closeButton.isBordered = false
        closeButton.imagePosition = .imageOnly
        closeButton.layer?.masksToBounds = false

        tabTitle.stringValue = tab.title

        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)

        closeButton.image = tab.icon
    }

    override open func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        closeButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        animator().alphaValue = 0.8
    }

    override open func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        closeButton.image = tab.icon
        animator().alphaValue = isSelectedTab ? 1 : 0.6
    }

    @objc func closeTab() {
        delegate?.tabBarItem?(self, wantsToClose: tab)
    }

    public required init(frame frameRect: NSRect, tab: MATab) {
        self.tab = tab
        isSelectedTab = tab.isSelectedTab
        super.init(frame: frameRect)
        configureViews()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
