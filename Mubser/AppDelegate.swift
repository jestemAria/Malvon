//
//  AppDelegate.swift
//  Mubser
//
//  Created by Ashwin Paudel on 29/11/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let window = MubWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.showWindow(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Functions
    
    @IBAction func showBrowsingHistory(_ sender: Any?) {
        let mainWindow = NSWindow(contentViewController: MubHistoryViewController(nibName: NSNib.Name("MubHistoryViewController"), bundle: nil))
        
        mainWindow.title = "History"
        mainWindow.titlebarAppearsTransparent = true
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func openNewApplicationWindow(_ sender: Any?) {
        let newWindow = MubWindowController()
        newWindow.showWindow(nil)
    }
}
