//
//  ViewController.swift
//  MATabViewExample
//
//  Created by Ashwin Paudel on 2022-02-03.
//

import Cocoa
import MATabView

class ViewController: NSViewController {

    @IBOutlet weak var tabView: MATabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newView = NSView(frame: .zero)
        newView.wantsLayer = true
        newView.layer?.backgroundColor = NSColor.red.cgColor
        tabView.create(tab: MATab(view: newView, title: "Tab0"))
        
        let newView1 = NSView(frame: .zero)
        newView1.wantsLayer = true
        newView1.layer?.backgroundColor = NSColor.yellow.cgColor
        tabView.create(tab: MATab(view: newView1, title: "Tab1"))
        
        if 1 == 1 {
            let newView1 = NSView(frame: .zero)
            newView1.wantsLayer = true
            newView1.layer?.backgroundColor = NSColor.yellow.cgColor
            tabView.create(tab: MATab(view: newView1, title: "Tab1"))
        }
        if 1 == 1 {
            let newView1 = NSView(frame: .zero)
            newView1.wantsLayer = true
            newView1.layer?.backgroundColor = NSColor.yellow.cgColor
            tabView.create(tab: MATab(view: newView1, title: "Tab1"))
        }
        if 1 == 1 {
            let newView1 = NSView(frame: .zero)
            newView1.wantsLayer = true
            newView1.layer?.backgroundColor = NSColor.yellow.cgColor
            tabView.create(tab: MATab(view: newView1, title: "Tab1"))
        }
        
        tabView.select(tab: 2)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

