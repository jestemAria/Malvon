//
//  MATabView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

// MARK: - Delegate Methods

@objc public protocol MATabViewDelegate: NSObjectProtocol {
    // Select Functions
    @objc optional func tabView(_ tabView: MATabView, willSelect tabViewItemIndex: Int)
    @objc optional func tabView(_ tabView: MATabView, didSelect tabViewItemIndex: Int)

    // Close Functions
    @objc optional func tabView(_ tabView: MATabView, willClose tabViewItemIndex: Int)
    @objc optional func tabView(_ tabView: MATabView, didClose tabViewItemIndex: Int)

    // Create New Tab Function
    @objc optional func tabView(_ tabView: MATabView, willCreateTab tabViewItemIndex: Int)
    @objc optional func tabView(_ tabView: MATabView, didCreateTab tabViewItemIndex: Int)

    // When there are no more tabs left
    @objc optional func tabView(noMoreTabsLeft tabView: MATabView)
}

open class MATabView: NSView, MATabBarViewDelegate {
    open var selectedTabViewItemIndex: Int = 0
    private var tabViews: [MATabViewItem] = []
    open weak var delegate: MATabViewDelegate?
    open var tabBar: MATabBarView?

    open var tabViewItems: Int {
        return tabViews.count
    }

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        tabBar?.delegate = self
    }

    open func getView(at index: Int) -> NSView? {
        if index > tabViews.count {
            return nil
        }
        return tabViews[index].view
    }

    public func tabBarView(_ tabBarView: MATabBarView, didSelect tabBarViewItemIndex: Int) {
        selectTabViewItem(at: tabBarViewItemIndex)
    }

    public func tabBarView(_ tabBarView: MATabBarView, wantsToClose tabBarViewItemIndex: Int) {
        removeTabViewItem(at: tabBarViewItemIndex)
    }

    open func selectTabViewItem(at index: Int) {
        selectTabViewItem(at: index, isNewTab: false)
    }

    private func selectTabViewItem(at index: Int, isNewTab: Bool = false) {
        // Call the delegate function
        delegate?.tabView?(self, willSelect: index)

        if tabBar!.tabViewItems != 0 {
            if let button = tabBar!.getTabItem(at: selectedTabViewItemIndex) {
                button.animator().alphaValue = 0.6
                button.isMainButton = false
            }
        }

        for subview in subviews {
            subview.removeFromSuperview()
        }
        // Add the new subview
        let newView = tabViews[index].view!
        autoresizesSubviews = true
        newView.setFrameSize(frame.size)
        addSubview(newView)
        newView.autoresizingMask = [.width, .height]

        selectedTabViewItemIndex = index

        if tabBar!.tabViewItems != 0 {
            if let button = tabBar!.getTabItem(at: selectedTabViewItemIndex) {
                if !isNewTab {
                    button.animator().alphaValue = 1
                }
                button.isMainButton = true
            }
        }

        // Call the delegate function
        delegate?.tabView?(self, didSelect: index)
    }

    open func addTabViewItem(tabViewItem: MATabViewItem) {
        delegate?.tabView?(self, willCreateTab: tabViews.count - 1)

        tabViews.append(tabViewItem)

        tabBar?.addTab(title: "New Tab")
        selectTabViewItem(at: tabViews.count - 1, isNewTab: true)
        if let button = tabBar!.getTabItem(at: selectedTabViewItemIndex) {
            button.isMainButton = true
        }
        delegate?.tabView?(self, didCreateTab: tabViews.count - 1)
    }

    open func removeTabViewItem(at index: Int) {
        delegate?.tabView?(self, willClose: index)
        if selectedTabViewItemIndex == index {
            // If there are no more tabs left
            if index == 0, tabViews.count == 1 {
                delegate?.tabView?(self, didClose: index)
                delegate?.tabView?(noMoreTabsLeft: self)
                return
            } else if index == 0, tabViews.count != 1 {
                selectTabViewItem(at: selectedTabViewItemIndex + 1)
                selectedTabViewItemIndex -= 1
                delegate?.tabView?(self, didClose: index)
                tabBar?.removeTab(at: index)
                tabViews.remove(at: index)
                if let button = tabBar!.getTabItem(at: selectedTabViewItemIndex) {
                    button.animator().alphaValue = 1
                    button.isMainButton = true
                }
                return
            } else {
                selectTabViewItem(at: selectedTabViewItemIndex - 1)
                delegate?.tabView?(self, didClose: index)
                tabBar?.removeTab(at: index)
                tabViews.remove(at: index)
                if let button = tabBar!.getTabItem(at: selectedTabViewItemIndex) {
                    button.animator().alphaValue = 1
                    button.isMainButton = true
                }
                return
            }
        }

        delegate?.tabView?(self, didClose: index)
        tabBar?.removeTab(at: index)
        tabViews.remove(at: index)
    }
}
