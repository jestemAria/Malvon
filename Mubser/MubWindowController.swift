//
//  MubWindowController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 29/11/2021.
//

import Cocoa

class MubWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.isMovableByWindowBackground = true
        self.contentViewController = MubViewController()
        
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar        
    }
    
    

    convenience init() {
        self.init(windowNibName: "MubWindowController")
    }
}
