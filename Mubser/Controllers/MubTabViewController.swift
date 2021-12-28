//
//  MubTabViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-12-05.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MubTabViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    var windowController: MubWindowController
    var tabViewController: NSTabViewController
    
    init(windowController: MubWindowController) {
        self.windowController = windowController
        self.tabViewController = self.windowController.tabViewController
        super.init(nibName: "MubTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.dataSource = self
        tableView.delegate = self
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Close Tab", action: #selector(closeTab), keyEquivalent: ""))
        tableView.menu = menu
        
        tableView.action = #selector(switchTabs)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tabViewController.tabViewItems.count
    }
    
    @objc func closeTab() {
        tabViewController.tabViewItems.remove(at: tableView.clickedRow)
        tableView.reloadData()
    }
    
    @objc func switchTabs() {
        tabViewController.selectedTabViewItemIndex = tableView.clickedRow
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TabsViewCell"), owner: self) as? MubTabsTableViewCell else { return nil }
        
        let VC = tabViewController.tabViewItems[row].viewController as? MubViewController
        
        let website: URL = VC?.website ?? URL(string: "https://www.google.com")!
        
        let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + website.absoluteString)
        let data = try? Data(contentsOf: url!)
        cell.TabIcon?.image = NSImage(data: data!)
        
        cell.TabTitle?.stringValue = VC?.title ?? "Untitled Tab"
        
        return cell
    }
}
