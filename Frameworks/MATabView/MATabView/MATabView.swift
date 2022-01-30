//
//  MATabView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

//  MARK: - TODO List

/**
    **1. Save the previous tab **
        *When the user closes the tab, go to the previous tab*
    **2. Error Handeling**
        *Fix a few errors*
    **3. Create a tabbar similar to Google Chrome's**
        *Try creating a vertical stack view*
    **4. Hidden Tabs that can be shown with a keyboard shortcut**
        *Good for privacy*
 */

import Cocoa

// MARK: - Delegate Methods

@objc public protocol MATabViewDelegate: NSObjectProtocol {
    @objc optional func tabView(_ tabView: MATabView, didSelect tabViewItemIndex: Int)
    @objc optional func tabViewDidChangeNumberOfTabViewItems(_ tabView: MATabView)
    @objc optional func tabView(_ tabView: MATabView, willRemove tabViewItemIndex: Int)

    /// When there are no more tabs left
    @objc optional func tabViewEmpty()
}

open class MATabView: NSView, MATabBarViewDelegate {
    open var selectedTabViewItemIndex: Int = 0
    open var tabViewItems: [MATabViewItem] = []
    open weak var delegate: MATabViewDelegate?
    open var tabBar: MATabBarView?

    open func `init`() {
        tabBar?.delegate = self
    }

    public func tabBarView(_ tabBarView: MATabBarView, didSelect tabBarViewItemIndex: Int) {
        selectTabViewItem(at: tabBarViewItemIndex)
    }

    public func tabBarView(_ tabBarView: MATabBarView, wantsToClose tabBarViewItemIndex: Int) {
        removeTabViewItem(at: tabBarViewItemIndex)
    }

    open func selectTabViewItem(at index: Int) {
        if !tabBar!.tabStackView.subviews.isEmpty {
            if let button = (tabBar?.tabStackView.subviews[selectedTabViewItemIndex] as? MATabBarViewItem) {
                button.alphaValue = 0.6
                button.isMainButton = false
            }
        }
        // Add the new subview
        let newView = tabViewItems[index].view!
        addSubview(newView)
        newView.autoresizingMask = [.width, .height]

        // Call the delegate function
        delegate?.tabView?(self, didSelect: index)

        selectedTabViewItemIndex = index

        if !tabBar!.tabStackView.subviews.isEmpty {
            if let button = (tabBar?.tabStackView.subviews[selectedTabViewItemIndex] as? MATabBarViewItem) {
                button.alphaValue = 1
                button.isMainButton = true
            }
        }
    }

    open func addTabViewItem(tabViewItem: MATabViewItem) {
        tabViewItems.append(tabViewItem)

        tabBar?.addTab(title: "New Tab")
        selectTabViewItem(at: tabViewItems.count - 1)
        if let button = (tabBar?.tabStackView.subviews[selectedTabViewItemIndex] as? MATabBarViewItem) {
            button.alphaValue = 1
            button.isMainButton = true
        }
    }

    open func removeTabViewItem(at index: Int) {
        if selectedTabViewItemIndex == index {
            // If there are no more tabs left
            if index == 0, tabViewItems.count == 1 {
                delegate?.tabView?(self, willRemove: index)
                delegate?.tabViewEmpty?()
                return
            } else if index == 0, tabViewItems.count != 1 {
                selectTabViewItem(at: selectedTabViewItemIndex + 1)
                selectedTabViewItemIndex -= 1
                delegate?.tabView?(self, willRemove: index)
                tabBar?.removeTab(at: index)
                tabViewItems.remove(at: index)
                if let button = (tabBar?.tabStackView.subviews[selectedTabViewItemIndex] as? MATabBarViewItem) {
                    button.alphaValue = 1
                    button.isMainButton = true
                }
                return
            } else {
                selectTabViewItem(at: selectedTabViewItemIndex - 1)
                delegate?.tabView?(self, willRemove: index)
                tabBar?.removeTab(at: index)
                tabViewItems.remove(at: index)
                if let button = (tabBar?.tabStackView.subviews[selectedTabViewItemIndex] as? MATabBarViewItem) {
                    button.alphaValue = 1
                    button.isMainButton = true
                }
                return
            }
        }

        delegate?.tabView?(self, willRemove: index)
        tabBar?.removeTab(at: index)
        tabViewItems.remove(at: index)
    }
}
