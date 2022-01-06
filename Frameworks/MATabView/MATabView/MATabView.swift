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
 */

import Cocoa

// MARK: - Delegate Methods
@objc public protocol MATabViewDelegate: NSObjectProtocol {
    @objc optional func tabView(_ tabView: MATabView, didSelect tabViewItemIndex: Int)
    @objc optional func tabViewDidChangeNumberOfTabViewItems(_ tabView: MATabView)
}

open class MATabView: NSView {
    open var selectedTabViewItemIndex: Int = 0
    open var tabViewItems: [MATabViewItem] = []
    open weak var delegate: MATabViewDelegate?
    
    open func selectTabViewItem(at index: Int) {
        // Remove the current view
        tabViewItems[selectedTabViewItemIndex].view?.removeFromSuperview()
        
        selectedTabViewItemIndex = index
        
        // Add the new view
        // TODO: - Error Handling
        guard let newView = tabViewItems[selectedTabViewItemIndex].view else { return }
        addSubview(newView)
        newView.autoresizingMask = [.width, .height]
        
        delegate?.tabView?(self, didSelect: index)
    }
    
    open func addTabViewItem(tabViewItem: MATabViewItem) {
        tabViewItems.append(tabViewItem)
        
        selectTabViewItem(at: tabViewItems.count - 1)
    }
    
    open func removeTabViewItem(at index: Int) {
        if selectedTabViewItemIndex == index {
            // TODO: - If they want to remove tab number 0, make sure it moves to tab number 1
                        // Switch to the previous tab
            selectTabViewItem(at: selectedTabViewItemIndex - 1)
        }
        tabViewItems.remove(at: index)
    }
}
