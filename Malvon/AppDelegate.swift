//
//  AppDelegate.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let window = MAWindowController()
    
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
        let mainWindow = NSWindow(contentViewController: MAHistoryViewController(nibName: NSNib.Name("MAHistoryViewController"), bundle: nil))
        window.window?.beginSheet(mainWindow, completionHandler: nil)
    }
    
    @IBAction func showDownloadHistory(_ sender: Any?) {
        let mainWindow = NSWindow(contentViewController: MADownloadsViewController(nibName: NSNib.Name("MADownloadsViewController"), bundle: nil))
        window.window?.beginSheet(mainWindow, completionHandler: nil)
    }
    
    @IBAction func openNewApplicationWindow(_ sender: Any?) {
        let newWindow = MAWindowController()
        newWindow.showWindow(nil)
    }
    
    @IBAction func removeTab(_ sender: Any?) {
        let VC = window.tabViewController.tabViewItems[window.tabViewController.selectedTabViewItemIndex].viewController as? MAViewController
        
        VC?.webView?.removeWebview()
        VC?.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        VC?.webView?.removeFromSuperview()
        VC?.webView = nil
        
        window.tabViewController.removeChild(at: window.tabViewController.selectedTabViewItemIndex)
    }
    
}

