//
//  MATabBarView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

@objc public protocol MATabBarViewDelegate: NSObjectProtocol {
    @objc optional func tabBarView(_ tabBarView: MATabBarView, didSelect tabBarViewItemIndex: Int)
    @objc optional func tabBarView(_ tabBarView: MATabBarView, wantsToClose tabBarViewItemIndex: Int)
}

open class MATabBarView: NSView, MATabBarViewItemDelegate {
    open var tabStackView: NSStackView = .init(frame: .zero)

    open weak var delegate: MATabBarViewDelegate?

    open func removeTab(at index: Int) {
        // Error Handling
        // We need to switch the tag of each button

        for (position, subview) in tabStackView.subviews.enumerated() {
            if position > index {
                (subview as? MATabBarViewItem)!.tag -= 1
            }
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true

            tabStackView.subviews[index].alphaValue = 0.0
        } completionHandler: { [self] in
            tabStackView.subviews[index].removeFromSuperview()
        }
    }

    @objc func didSelectTab(_ sender: MATabBarViewItem) {
        delegate?.tabBarView?(self, didSelect: sender.tag)
    }

    open func addTab(title: String) {
        let newButton = MATabBarViewItem(frame: .zero)

        newButton.translatesAutoresizingMaskIntoConstraints = true
        newButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        newButton.widthAnchor.constraint(equalToConstant: 225).isActive = true
        newButton.tag = tabStackView.subviews.count

        newButton.label = title
        newButton.title = ""
        newButton.target = self
        newButton.action = #selector(didSelectTab(_:))

        newButton.bezelStyle = .shadowlessSquare

        newButton.delegate = self

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true

            tabStackView.addArrangedSubview(newButton)
        }
    }

    public func tabBarViewItem(_ tabBarViewItem: MATabBarViewItem, wantsToClose tabBarViewItemIndex: Int) {
        delegate?.tabBarView?(self, wantsToClose: tabBarViewItemIndex)
    }

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabStackView)

        tabStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tabStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tabStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabStackView.orientation = .horizontal
        tabStackView.distribution = .gravityAreas
        tabStackView.alignment = .centerY
        tabStackView.spacing = 0.3
    }
}
