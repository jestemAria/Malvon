//
//  MATabBarView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//
//
//  Some code from: https://stackoverflow.com/questions/10016475/create-nsscrollview-programmatically-in-an-nsview-cocoa/55219153

import Cocoa

@objc public protocol MATabBarViewDelegate: NSObjectProtocol {
    @objc optional func tabBarView(_ tabBarView: MATabBarView, didSelect tabBarViewItemIndex: Int)
    @objc optional func tabBarView(_ tabBarView: MATabBarView, wantsToClose tabBarViewItemIndex: Int)
}

final class FlippedClipView: NSClipView {
    override var isFlipped: Bool {
        return true
    }
}

open class MATabBarView: NSView, MATabBarViewItemDelegate {
    open var tabStackView = NSStackView()
    private let scrollView: NSScrollView = .init()

    open weak var delegate: MATabBarViewDelegate?
    let clipView = FlippedClipView()

    open func removeTab(at index: Int) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true

            tabStackView.subviews[index].alphaValue = 0.0
        } completionHandler: { [self] in
            tabStackView.subviews[index].removeFromSuperview()
        }

        // Remap the tags of each button
        for (position, subview) in tabStackView.subviews.enumerated() {
            (subview as! MATabBarViewItem).tag = position
        }
    }

    @objc func didSelectTab(_ sender: MATabBarViewItem) {
        delegate?.tabBarView?(self, didSelect: sender.tag)
    }

    open func addTab(title: String) {
        let newButton = MATabBarViewItem(frame: .zero)

        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        newButton.widthAnchor.constraint(equalToConstant: 225).isActive = true
        newButton.tag = tabStackView.subviews.count

        newButton.label = title
        newButton.title = ""
        newButton.target = self
        newButton.action = #selector(didSelectTab(_:))

        newButton.bezelStyle = .shadowlessSquare

        newButton.delegate = self

        tabStackView.addArrangedSubview(newButton)
    }

    public func tabBarViewItem(_ tabBarViewItem: MATabBarViewItem, wantsToClose tabBarViewItemIndex: Int) {
        delegate?.tabBarView?(self, wantsToClose: tabBarViewItemIndex)
    }

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = false
        scrollView.hasVerticalRuler = false
        scrollView.drawsBackground = false
        scrollView.verticalScrollElasticity = .none

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 30)
        ])

        clipView.drawsBackground = false
        scrollView.contentView = clipView
        clipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            clipView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            clipView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            clipView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        scrollView.documentView = tabStackView
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabStackView.leftAnchor.constraint(equalTo: clipView.leftAnchor),
            tabStackView.topAnchor.constraint(equalTo: clipView.topAnchor),
            tabStackView.bottomAnchor.constraint(equalTo: clipView.bottomAnchor)
        ])

        tabStackView.orientation = .horizontal
        tabStackView.distribution = .gravityAreas
        tabStackView.alignment = .centerY
        tabStackView.spacing = 05
    }
}
