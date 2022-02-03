//
//  AppDelegate.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MATools
import Unique

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
        window.showWindow(nil)
        updateApplication()
        // setAsDefaultBrowser()
        testClassWrapper().parseHTML("hello world")
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
        for url in urls {
            // Create a new window if there are no windows
            if application.windows.isEmpty {
                window.showWindow(nil)
            }
            if url.isFileURL || (url.host != nil && url.scheme != nil) {
                let VC = application.mainWindow?.contentViewController as? MAViewController
                VC!.createNewTab(url: url)
            }
            // Functions
            if let range = url.absoluteString.range(of: "open?") {
                let value = url.absoluteString[range.upperBound...]
                if String(value).isValidURL {
                    let VC = application.mainWindow?.contentViewController as? MAViewController
                    VC!.createNewTab(url: URL(string: String(value))!)
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Invalid URL"
                    alert.informativeText = "This is not a valid URL"
                    
                    alert.addButton(withTitle: "Ok")
                    
                    alert.runModal()
                }
            }
        }
    }
    
    func updateApplication() {
        let newestVersion = MAURL("https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/version.txt").contents().removeWhitespace
        
        if MA_APP_VERSION != newestVersion, !newestVersion.isEmpty {
            if askForPermissions() {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["\(Bundle.main.bundlePath)/Contents/Applications/Malvon\\ Updater.app"]
                task.launch()
                exit(0)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            let newWindow = MAWindowController()
            newWindow.showWindow(nil)
        }
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
        let newWindow = MAWindowController(windowNibName: "MAWindowController")
        newWindow.showWindow(nil)
    }
    
    var preferencesController: NSWindowController?
    
    @IBAction func showPreferences(_ sender: Any) {
        if preferencesController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if preferencesController != nil {
            preferencesController!.showWindow(sender)
        }
    }
    
    // MARK: - Other

    public func setAsDefaultBrowser() {
        let bundleID = Bundle.main.bundleIdentifier as CFString?
        var httpResult: OSStatus?
        if let bundleID = bundleID {
            httpResult = LSSetDefaultHandlerForURLScheme("http" as CFString, bundleID)
            print(httpResult!)
        }
        var httpsResult: OSStatus?
        if let bundleID = bundleID {
            httpsResult = LSSetDefaultHandlerForURLScheme("https" as CFString, bundleID)
            print(httpsResult!)
        }
        
        var fileResult: OSStatus?
        if let bundleID = bundleID {
            fileResult = LSSetDefaultHandlerForURLScheme("HTML document" as CFString, bundleID)
            print(fileResult!)
        }
        
        var XHTMLdoc: OSStatus?
        if let bundleID = bundleID {
            XHTMLdoc = LSSetDefaultHandlerForURLScheme("XHTML document" as CFString, bundleID)
            print(XHTMLdoc!)
        }
    }
}
