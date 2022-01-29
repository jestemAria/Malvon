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

    open func selectTabViewItem(at index: Int) {
        subviews.forEach { subview in
            subview.isHidden = true
        }
        // Make a switch first, then remove the old view
        let newView = tabViewItems[index].view!
        addSubview(newView)
        newView.autoresizingMask = [.width, .height]
        newView.isHidden = false
        delegate?.tabView?(self, didSelect: index)

        // Remove the current view
        // Just in case they selected the same tab
        if selectedTabViewItemIndex == index {
            tabViewItems[selectedTabViewItemIndex].view?.isHidden = false
        } else {
            tabViewItems[selectedTabViewItemIndex].view?.isHidden = true
        }

        selectedTabViewItemIndex = index
    }

    open func addTabViewItem(tabViewItem: MATabViewItem) {
        tabViewItems.append(tabViewItem)

        selectTabViewItem(at: tabViewItems.count - 1)

        tabBar?.addTab(title: "New Tab \(tabViewItems.count - 1)")
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
                return
            } else {
                selectTabViewItem(at: selectedTabViewItemIndex - 1)
                delegate?.tabView?(self, willRemove: index)
                tabBar?.removeTab(at: index)
                tabViewItems.remove(at: index)
                return
            }
        }
        delegate?.tabView?(self, willRemove: index)
        tabBar?.removeTab(at: index)
        tabViewItems.remove(at: index)
    }
}
