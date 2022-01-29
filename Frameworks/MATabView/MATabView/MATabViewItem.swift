//
//  MATabViewItem.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

// Some code used from: https://github.com/robin/LYTabView
open class MATabViewItem: NSObject {
    open var view: NSView?
    open var title: String?
    open var tabView: MATabView?
    open var index: Int?
    open var image: NSImage?

    public convenience init(view: NSView) {
        self.init()
        self.view = view
    }

    override public init() {}
}

@objc public protocol MATabBarViewItemDelegate: NSObjectProtocol {
    @objc optional func tabBarViewItem(_ tabBarViewItem: MATabBarViewItem, wantsToClose tabBarViewItemIndex: Int)
}

open class MATabBarViewItem: NSButton {
    open var item: MATabViewItem?
    open weak var delegate: MATabBarViewItemDelegate?

    let tabTitle = NSTextField(frame: .zero)
    var closeButton = NSButton(frame: .zero)

    var isMainButton = false

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
        title = ""
        let position = xPosition * 2 + closeButtonSize.width

        // Tab Title
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

        // Close Button
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
        closeButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        closeButton.bezelStyle = .shadowlessSquare
        closeButton.isBordered = false
        closeButton.imagePosition = .imageOnly

        // Self
        wantsLayer = true
        layer?.cornerRadius = 10
        setButtonType(.momentaryPushIn)
        image = nil
        layer?.backgroundColor = .black

        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
    }

    override open func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        animator().alphaValue = 0.8
    }

    override open func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        animator().alphaValue = isMainButton ? 1 : 0.6
    }

    @objc func closeTab() {
        delegate?.tabBarViewItem?(self, wantsToClose: tag)
    }
}
