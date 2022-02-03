//
//  MATabBarItem.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-02-02.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//
// Some code used from: https://github.com/robin/LYTabView

import Cocoa

@objc public protocol MATabBarItemDelegate: NSObjectProtocol {
    @objc optional func tabBarViewItem(_ tabBarViewItem: MATabBarItem, wantsToClose tabBarViewItemIndex: Int)
}

open class MATabBarItem: NSButton {
    open var item: MATabViewItem?
    open weak var delegate: MATabBarItemDelegate?

    let tabTitle = NSTextField(frame: .zero)
    open var closeButton = NSButton(frame: .zero)

    var isMainButton = false

    var xPosition: CGFloat = 4
    var yPosition: CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    private var _favicon: NSImage?

    public var tabBarView: MATabBarView?

    // Drag and Droping
    private var dragOffset: CGFloat?
    private var isDragging = false
    private var draggingView: NSImageView?
    private var draggingViewLeadingConstraint: NSLayoutConstraint?

    open var favicon: NSImage? {
        get {
            return _favicon
        }
        set(image) {
            _favicon = image as NSImage?
            closeButton.image = _favicon
        }
    }

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
        // Tab Title
        setUpTitle()

        // Close Button
        setUpCloseButton()

        // Background and corner radius
        let bgColor: NSColor = .quaternaryLabelColor
        layer?.cornerRadius = 4
        layer?.masksToBounds = true
        layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        dirtyRect.fill()

        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
    }

    fileprivate func setUpTitle() {
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
    }

    fileprivate func setUpCloseButton() {
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

        closeButton.image = favicon
    }

    override open func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        closeButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        animator().alphaValue = 0.8
    }

    override open func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        closeButton.image = favicon
        animator().alphaValue = isMainButton ? 1 : 0.6
    }

    @objc func closeTab() {
        delegate?.tabBarViewItem?(self, wantsToClose: tag)
    }

    // TODO: - Dragging Session
}
