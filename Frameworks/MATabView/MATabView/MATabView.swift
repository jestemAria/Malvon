//
//  MATabView.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

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
        willRemoveSubview(tabViewItems[selectedTabViewItemIndex].view!)
        
        selectedTabViewItemIndex = index
        
        print(tabViewItems.count)
        
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
            selectTabViewItem(at: selectedTabViewItemIndex - 1)
        }
        tabViewItems.remove(at: index)
    }
}
