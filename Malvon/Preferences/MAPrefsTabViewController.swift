//
//  MAPrefsTabViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-31.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MAPrefsTabViewController: NSViewController {
    var properties = AppProperties()
    
    @IBOutlet var hidesScreenElementsWhenNotActive: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        properties.hidesScreenElementsWhenNotActive ? setState(hidesScreenElementsWhenNotActive, .on) : setState(hidesScreenElementsWhenNotActive, .off)
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
        } else {}
    }
    
    @IBAction func hidesScreenElementsWhenNotActiveAction(_ sender: NSButton) {
        if properties.hidesScreenElementsWhenNotActive == true {
            properties.hidesScreenElementsWhenNotActive = false
        } else if properties.hidesScreenElementsWhenNotActive == false {
            properties.hidesScreenElementsWhenNotActive = true
        }
        properties.set()
        
        relaunchAlert()
    }
}
