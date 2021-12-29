//
//  AppDelegate.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-11-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
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
    
    // MARK: - Menu Bar Functions
    
    @IBAction func showBrowsingHistory(_ sender: Any?) {
        let mainWindow = NSWindow(contentViewController: MubHistoryViewController(nibName: NSNib.Name("MubHistoryViewController"), bundle: nil))
        window.window?.beginSheet(mainWindow, completionHandler: nil)
    }
    
    @IBAction func showDownloadHistory(_ sender: Any?) {
        let mainWindow = NSWindow(contentViewController: MubDownloadsViewController(nibName: NSNib.Name("MubDownloadsViewController"), bundle: nil))
        window.window?.beginSheet(mainWindow, completionHandler: nil)
    }
    
    @IBAction func openNewApplicationWindow(_ sender: Any?) {
        let newWindow = MubWindowController()
        newWindow.showWindow(nil)
    }
    
    @IBAction func removeTab(_ sender: Any?) {
        let VC = window.tabViewController.tabViewItems[window.tabViewController.selectedTabViewItemIndex].viewController as? MubViewController
        VC?.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        VC?.webView?.removeFromSuperview()
        VC?.webView = nil
        
        window.tabViewController.removeChild(at: window.tabViewController.selectedTabViewItemIndex)
    }
}
