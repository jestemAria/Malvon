//
//  MATabViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-05.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MAWebView

class MATabViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    var viewController: MAViewController

    init(viewController: MAViewController) {
        self.viewController = NSApp.mainWindow?.contentViewController as! MAViewController
        super.init(nibName: "MATabViewController", bundle: nil)
    }

    @available(*, unavailable)
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
        tableView.doubleAction = #selector(switchTabs)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewController.webTabView.tabViewItems.count
    }

    @objc func closeTab() {
        var tabsWebView = viewController.webTabView.tabViewItems[viewController.webTabView.selectedTabViewItemIndex].view as? MAWebView

        // Make the webView load "about:blank"
        tabsWebView?.load(URLRequest(url: URL(string: "about:blank")!))
        // Remove all the observers on the webview
        tabsWebView?.removeWebview()
        // Remove from the superview
        tabsWebView?.removeFromSuperview()
        // Make it nil
        tabsWebView = nil

        // Remove the tab item
        viewController.webTabView.removeTabViewItem(at: tableView.clickedRow)

        tableView.reloadData()
    }

    @objc func switchTabs() {
        viewController.webTabView.selectTabViewItem(at: tableView.clickedRow)
        view.window?.close()
    }

    @IBAction func willPressClose(_ sender: NSButton) {
        viewController.webTabView.removeTabViewItem(at: sender.tag)

        tableView.reloadData()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TabsViewCell"), owner: self) as? MATabsTableViewCell else { return nil }

        let VC = viewController.webTabView.tabViewItems[row]

//        if VC.title == nil || VC.image == nil || ((VC.view as! MAWebView).title ?? "Untitled Tab") != VC.title {
        cell.TabTitle?.stringValue = (VC.view as! MAWebView).title ?? "Untitled Tab"

        if let webViewURL = (VC.view as! MAWebView).url?.absoluteString {
            let url = URL(string: "https://www.google.com/s2/favicons?sz=30&domain_url=" + webViewURL)

            let data: Data

            do {
                data = try Data(contentsOf: url!)
                cell.TabIcon?.image = NSImage(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
//        } else {
//            cell.TabIcon?.image = VC.image
//            cell.TabTitle.stringValue = VC.title!
//        }

        cell.TabCloseButton.tag = row
        cell.TabCloseButton.action = #selector(willPressClose(_:))

        return cell
    }
}
