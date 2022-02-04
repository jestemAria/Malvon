//
//  MATabView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

@objc public protocol MATabViewDelegate: NSObjectProtocol {
    // Select Functions
    @objc optional func tabView(_ tabView: MATabView, willSelect tab: MATab)
    @objc optional func tabView(_ tabView: MATabView, didSelect tab: MATab)

    // Close Functions
    @objc optional func tabView(_ tabView: MATabView, willClose tab: MATab)
    @objc optional func tabView(_ tabView: MATabView, didClose tab: MATab)

    // Create New Tab Function
    @objc optional func tabView(_ tabView: MATabView, willCreateTab tab: MATab)
    @objc optional func tabView(_ tabView: MATabView, didCreateTab tab: MATab)

    // When there are no more tabs left
    @objc optional func tabView(noMoreTabsLeft tabView: MATabView)
}

open class MATabView: NSView, MATabBarDelegate {
    open var selectedTab: MATab?
    open var tabs = [MATab]()
    open weak var delegate: MATabViewDelegate?
    private var tabBar = MATabBar(frame: .zero)

    open var configuration = MATabViewConfiguration()

    // MARK: - Configuring

    private final func configureViews() {
        tabBar.delegate = self
        addSubview(tabBar)

        tabBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabBar.heightAnchor.constraint(equalToConstant: configuration.tabHeight),
            tabBar.topAnchor.constraint(equalTo: topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bgColor: NSColor = .white
        layer?.masksToBounds = true
        layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        dirtyRect.fill()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }

    override public required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureViews()
    }

    // MARK: - Tabs Controls

    open func select(tab: Int) {
        select(tab: tabs[tab])
    }

    open func select(tab: MATab, isNewTab: Bool = false) {
        delegate?.tabView?(self, willSelect: tab)

        if !(tabBar.isEmpty()) {
            let oldTab = tabBar.get(tabItem: selectedTab!.position)
            oldTab.animator().alphaValue = 0.6
            oldTab.isSelectedTab = false
        }

        selectedTab?.isSelectedTab = false

        selectedTab?.view.removeFromSuperview()

        let frameSize = NSSize(width: frame.width, height: frame.height - 30)

        tab.view.setFrameSize(frameSize)
        addSubview(tab.view)
        tab.view.autoresizingMask = [.width, .height]

        selectedTab = tab
//
        if !isNewTab {
            let newTab = tabBar.get(tabItem: tab.position)
            newTab.alphaValue = 0.0
            newTab.isSelectedTab = true

            newTab.animator().alphaValue = 1.0
        }

        selectedTab!.isSelectedTab = true

        delegate?.tabView?(self, didSelect: tab)
    }

    open func create(tab: MATab) {
        delegate?.tabView?(self, willCreateTab: tab)

        // Configure the tab
        tab.position = tabs.count

        tabs.append(tab)
        select(tab: tab, isNewTab: true)
        tabBar.add(tab: tab)

        delegate?.tabView?(self, didCreateTab: tab)
    }

    open func remove(tab: Int) {
        remove(tab: tabs[tab])
    }

    open func remove(tab: MATab) {
        delegate?.tabView?(self, willClose: tab)

        if tabs.isEmpty || tabBar.tabCount == 1 {
            delegate?.tabView?(noMoreTabsLeft: self)
            return
        } else if (tabs.count - 1) != 0 || (tabs.count - 1) == 1 {
            if selectedTab?.position == 0 {
                selectedTab = tabs[selectedTab!.position + 1]
            } else {
                selectedTab = tabs[selectedTab!.position - 1]
            }
            select(tab: selectedTab!)
        }

        tabs.remove(at: tab.position)
        tabBar.remove(tab: tab)

        for (index, tab) in tabs.enumerated() {
            tab.position = index
        }

        delegate?.tabView?(self, didClose: tab)
    }

    // MARK: - Tab Bar

    public func tabBar(_ tabBarView: MATabBar, didSelect tab: MATab) {
        select(tab: tab)
    }

    public func tabBar(_ tabBarView: MATabBar, wantsToClose tab: MATab) {
        remove(tab: tab)
    }

    // MARK: - Get & Set

    public func get(tab at: Int) -> MATab {
        tabs[at]
    }

    open func set(tab at: Int, title: String) {
        tabs[at].title = title
        tabBar.get(tabItem: at).tab.title = title
        tabBar.get(tabItem: at).tabTitle.stringValue = title
    }

    open func set(tab at: Int, icon: NSImage) {
        tabs[at].icon = icon
        tabBar.get(tabItem: at).tab.icon = icon
        tabBar.get(tabItem: at).closeButton.image = icon
    }
}
