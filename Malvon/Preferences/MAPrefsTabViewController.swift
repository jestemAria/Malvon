//
//  MAPrefsTabViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-31.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MAPrefsTabViewController: NSViewController {
    
    var properties = AppProperties()
    
    @IBOutlet weak var showBlackScreenButton: NSButton!
    
    @IBOutlet weak var showTabBarButton: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        properties.showsTabBar ? setState(showTabBarButton, .on) : setState(showTabBarButton, .off)
        
        properties.showsBlackScreen ? setState(showBlackScreenButton, .on) : setState(showBlackScreenButton, .off)
    }
    
    func setState(_ button: NSButton, _ state: NSControl.StateValue) {
        button.state = state
    }
    
    
    func relaunchAlert() {
        let alert = NSAlert()
        alert.messageText = "Relaunch Required"
        alert.informativeText = "Relaunch is required to make changes"
        
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        alert.alertStyle = .warning
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            let task = Process()
            var args = [String]()
            args.append("-c")
            let bundle = Bundle.main.bundlePath
            args.append("sleep 0.2; open \"\(bundle)\"")
            task.launchPath = "/bin/sh"
            task.arguments = args
            task.launch()
            NSApplication.shared.terminate(nil)
        } else {
            
        }
    }
    
    
    @IBAction func showsTabBar(_ sender: NSButton) {
        if properties.showsTabBar == true {
            properties.showsTabBar = false
        } else if properties.showsTabBar == false {
            properties.showsTabBar = true
        }
        properties.set()
        
        relaunchAlert()
    }
    @IBAction func showBlackScreen(_ sender: Any) {
        if properties.showsBlackScreen == true {
            properties.showsBlackScreen = false
        } else if properties.showsBlackScreen == false {
            properties.showsBlackScreen = true
        }
        properties.set()
    }
}
