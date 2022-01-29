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
}

open class MATabBarView: NSView {
    open var tabStackView: NSStackView = .init(frame: .zero)
    
    open weak var delegate: MATabBarViewDelegate?
    
    open func removeTab(at index: Int) {
        tabStackView.subviews[index].removeFromSuperview()
    }
    
    @objc func didSelectTab(_ sender: NSButton) {
        delegate?.tabBarView?(self, didSelect: sender.tag)
    }
    
    open func addTab(title: String) {
        let newButton = NSButton()
        newButton.translatesAutoresizingMaskIntoConstraints = true
        newButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        newButton.widthAnchor.constraint(equalTo: .init(), multiplier: 0.5).isActive = true
//        let width = newButton.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
            
        newButton.tag = tabStackView.subviews.count
        
        newButton.title = title
        
        newButton.target = self
        newButton.action = #selector(didSelectTab(_:))
        
        tabStackView.addArrangedSubview(newButton)
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
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .top
        tabStackView.spacing = 1
        tabStackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        
//        let newView = NSView(frame: .init(x: 0, y: 0, width: 50, height: 30))
//
//        newView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        newView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        newView.layer?.backgroundColor = .white
//
//        tabStackView.addArrangedSubview(convertItemToView(item: .init(view: NSView())))
    }
}
