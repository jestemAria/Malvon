//
//  ViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 02/12/2021.
//

import Cocoa
import MubTabView

class TabViewController: NSViewController {
    @IBOutlet var tabView: MubTabView!
    var tabBarView: MubTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tabBarView = tabView.tabBarView

        addViewWithLabel("Tab", aTabBarView: tabBarView, fromTabView: true)

        tabBarView.minTabHeight = 28
        tabBarView.minTabItemWidth = 120
        tabBarView.hideIfOnlyOneTabExists = false
        tabBarView?.addNewTabButtonAction = #selector(addNewTab)
    }

    func addViewWithLabel(_ label: String, aTabBarView: MubTabBarView, fromTabView: Bool = false) {
        let item = NSTabViewItem()
        item.label = label

        item.view = MubViewController(nibName: "MubViewController", bundle: nil).view

        if fromTabView {
            tabView.tabView.addTabViewItem(item)
        } else {
            aTabBarView.addTabViewItem(item, animated: true)
        }
    }

    @IBAction func addNewTab(_ sender: AnyObject?) {
        if let tabBarView = (sender as? MubTabBarView) ?? tabBarView {
            let count = tabBarView.tabViewItems.count
            let label = "Untitled \(count)"
            addViewWithLabel(label, aTabBarView: tabBarView)
        }
    }
}
