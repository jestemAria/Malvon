//
//  MAWindowController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//

import Cocoa

class MAWindowController: NSWindowController {
    
    lazy var tabViewController: NSTabViewController = {
        let tabVC = NSTabViewController()
        tabVC.addTabViewItem(NSTabViewItem(viewController: MAViewController()))
        
        tabVC.tabStyle = .unspecified
        return tabVC
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        shouldCascadeWindows = false
        window?.setFrameAutosaveName("MAWindowControllerWindowState")
        
        self.contentViewController = tabViewController
        
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar
    }
    
    convenience init() {
        self.init(windowNibName: "MAWindowController")
    }
    
    @IBAction func closeWindowController(_ sender: Any?) {
        self.close()
    }
}
