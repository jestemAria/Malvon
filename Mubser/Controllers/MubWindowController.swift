//
//  MubWindowController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MubWindowController: NSWindowController {
    
    lazy var tabViewController: NSTabViewController = {
        let tabVC = NSTabViewController()
        tabVC.addTabViewItem(NSTabViewItem(viewController: MubViewController()))
        
        tabVC.tabStyle = .unspecified
        return tabVC
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.contentViewController = tabViewController
        
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar
    }
    
    convenience init() {
        self.init(windowNibName: "MubWindowController")
    }
    
    @IBAction func closeWindow(_ sender: Any?) {
        self.close()
    }
}
