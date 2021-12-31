//
//  MAWindowController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MAWindowController: NSWindowController {
    
    let properties = AppProperties()
    
    lazy var tabViewController: NSTabViewController = {
        let tabVC = NSTabViewController()
        
        var tabItem = NSTabViewItem(viewController: MAViewController())
        tabItem.viewController = MAViewController(tabItem)
        
        tabVC.addTabViewItem(tabItem)
        
        if !properties.showsTabBar {
            tabVC.tabView.tabViewType = .noTabsNoBorder
            tabVC.tabStyle = .unspecified
        }
        return tabVC
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        shouldCascadeWindows = false
        window?.setFrameAutosaveName(window!.representedFilename)
        self.contentViewController = tabViewController
        
        if !properties.showsTabBar {
            let customToolbar = NSToolbar()
            window?.titleVisibility = .hidden
            window?.toolbar = customToolbar
        }
    }
    
    convenience init() {
        self.init(windowNibName: "MAWindowController")
    }
    
    @IBAction func closeWindowController(_ sender: Any?) {
        self.close()
    }
    
    
    // https://stackoverflow.com/questions/52150960/double-click-on-transparent-nswindow-title-does-not-maximize-the-window
    
    override func mouseUp(with event: NSEvent) {
        if event.clickCount >= 2 && cursorIsOnTitlebar(event.locationInWindow) {
            self.window?.performZoom(nil)
        }
        super.mouseUp(with: event)
    }
    
    fileprivate func cursorIsOnTitlebar(_ point: CGPoint) -> Bool {
        if let windowFrame = self.window?.contentView?.frame {
            let titleBarRect = NSRect(x: self.window!.contentLayoutRect.origin.x, y: self.window!.contentLayoutRect.origin.y+self.window!.contentLayoutRect.height, width: self.window!.contentLayoutRect.width, height: windowFrame.height-self.window!.contentLayoutRect.height)
            return titleBarRect.contains(point)
        }
        return false
    }
}
