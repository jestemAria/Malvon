//
//  AppDelegate.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MATools

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let window = MAWindowController()
    
    func askForPermissions() -> Bool {
        let alert = NSAlert()
        alert.messageText = "New updates are available!"
        alert.informativeText = "Would you like to install the updates?"
        
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            return true
        } else {
            return false
        }
    }
    
    let MA_APP_VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if MA_APP_VERSION != MAURL("https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/version.txt").contents().removeWhitespace {
            if askForPermissions() {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["/Applications/Malvon.app/Contents/Applications/Malvon\\ Updater.app"]
                task.launch()
                exit(0)
            }
        }
        
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
        
        VC?.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        
        VC?.webView?.removeWebview()
        VC?.webView?.removeFromSuperview()
        VC?.webView = nil
        
        window.tabViewController.removeChild(at: window.tabViewController.selectedTabViewItemIndex)
    }
    
}

