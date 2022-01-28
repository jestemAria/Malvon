//
//  MAWindowController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MAWindowController: NSWindowController {
    let properties = AppProperties()
    
    let windowState = "MAWindowControllerWindowState"
    
    override func windowDidLoad() {
        super.windowDidLoad()
        shouldCascadeWindows = false

        self.contentViewController = MAViewController(windowCNTRL: self)

        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar
        
        let data = UserDefaults.standard.object(forKey: self.windowState) as? String ?? ""
        window?.setFrame(NSRectFromString(data), display: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowWillClose), name: NSWindow.willCloseNotification, object: nil)
    }
    
    convenience init() {
        self.init(windowNibName: "MAWindowController")
    }
    
    @IBAction func closeWindowController(_ sender: Any?) {
        self.close()
    }
    
    // MARK: - Position

    @objc func windowWillClose() {
        guard let frame = window?.frame else { return }
        UserDefaults.standard.set(NSStringFromRect(frame), forKey: windowState)
    }
    
    // MARK: - TitleBar

    // https://stackoverflow.com/questions/52150960/double-click-on-transparent-nswindow-title-does-not-maximize-the-window
    
    override func mouseUp(with event: NSEvent) {
        if event.clickCount >= 2, self.cursorIsOnTitlebar(event.locationInWindow) {
            self.window?.performZoom(nil)
        }
        super.mouseUp(with: event)
    }
    
    fileprivate func cursorIsOnTitlebar(_ point: CGPoint) -> Bool {
        if let windowFrame = self.window?.contentView?.frame {
            let titleBarRect = NSRect(x: self.window!.contentLayoutRect.origin.x, y: self.window!.contentLayoutRect.origin.y + self.window!.contentLayoutRect.height, width: self.window!.contentLayoutRect.width, height: windowFrame.height - self.window!.contentLayoutRect.height)
            return titleBarRect.contains(point)
        }
        return false
    }
}
