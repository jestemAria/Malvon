//
//  MATabViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-05.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MATabViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    var windowController: MAWindowController
    var tabViewController: NSTabViewController
    var tabViewItem: NSTabViewItem
    
    init(windowController: MAWindowController, _ tabViewItem: NSTabViewItem) {
        self.windowController = windowController
        self.tabViewItem = tabViewItem
        self.tabViewController = self.windowController.tabViewController
        super.init(nibName: "MATabViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        (windowController.contentViewController as? MAViewController)?.tabsPopover.performClose(nil)
        
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
        let VC = tabViewController.tabViewItems[tableView.clickedRow].viewController as? MAViewController
        
        VC?.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        
        VC?.webView?.removeWebview()
        VC?.webView?.removeFromSuperview()
        VC?.webView = nil
        
        tabViewController.removeChild(at: tableView.clickedRow)
        tableView.reloadData()
    }
    
    @objc func switchTabs() {
        tabViewController.selectedTabViewItemIndex = tableView.clickedRow
    }
    
    @IBAction func willPressClose(_ sender: NSButton) {
        let VC = tabViewController.tabViewItems[sender.tag].viewController as? MAViewController
        
        VC?.webView?.load(URLRequest(url: URL(string: "about:blank")!))
        
        VC?.webView?.removeWebview()
        VC?.webView?.removeFromSuperview()
        VC?.webView = nil
        
        tabViewController.removeChild(at: sender.tag)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TabsViewCell"), owner: self) as? MATabsTableViewCell else { return nil }
        let VC = tabViewController.tabViewItems[row].viewController as? MAViewController
        
        cell.TabIcon?.image = VC?.favicon
        cell.TabTitle?.stringValue = tabViewItem.label
        cell.TabCloseButton.tag = row
        cell.TabCloseButton.action = #selector(willPressClose(_:))
        
        return cell
    }
}
