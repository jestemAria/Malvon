//
//  MubTabView.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/LYTabView

import Cocoa

/// Description
public class MubTabView: NSView {
    /// Tab bar view of the MubTabView
    public let tabBarView = MubTabBarView(frame: .zero)

    /// Native NSTabView of the MubTabView
    public let tabView = NSTabView(frame: .zero)

    //
    private let stackView = NSStackView(frame: .zero)

    /// delegate of MubTabView
    public var delegate: NSTabViewDelegate? {
        get {
            return tabBarView.delegate
        }
        set(newDelegate) {
            tabBarView.delegate = newDelegate
        }
    }

    public var numberOfTabViewItems: Int { return tabView.numberOfTabViewItems }
    public var tabViewItems: [NSTabViewItem] { return tabView.tabViewItems }
    public var selectedTabViewItem: NSTabViewItem? { return tabView.selectedTabViewItem }

    private final func setupViews() {
        tabView.delegate = tabBarView
        tabView.tabViewType = .noTabsNoBorder
        tabBarView.tabView = tabView

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addView(tabBarView, in: .center)
        stackView.addView(tabView, in: .center)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.alignment = .centerX
        stackView.spacing = 0
        stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor).isActive = true

        stackView.leadingAnchor.constraint(equalTo: tabView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: tabView.trailingAnchor).isActive = true

        let lowerPriority = NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.defaultLow.rawValue - 10)
        tabView.setContentHuggingPriority(lowerPriority, for: .vertical)
        tabBarView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultHigh, for: .vertical)
        tabBarView.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .vertical)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override public required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
}

public extension MubTabView {
    func addTabViewItem(_ tabViewItem: NSTabViewItem) {
        tabBarView.addTabViewItem(tabViewItem)
    }

    func insertTabViewItem(_ tabViewItem: NSTabViewItem, atIndex index: Int) {
        tabView.insertTabViewItem(tabViewItem, at: index)
    }

    func removeTabViewItem(_ tabViewItem: NSTabViewItem) {
        tabBarView.removeTabViewItem(tabViewItem)
    }

    func indexOfTabViewItem(_ tabViewItem: NSTabViewItem) -> Int {
        return tabView.indexOfTabViewItem(tabViewItem)
    }

    func indexOfTabViewItemWithIdentifier(_ identifier: AnyObject) -> Int {
        return tabView.indexOfTabViewItem(withIdentifier: identifier)
    }

    func tabViewItem(at index: Int) -> NSTabViewItem {
        return tabView.tabViewItem(at: index)
    }

    func selectFirstTabViewItem(_ sender: AnyObject?) {
        tabView.selectFirstTabViewItem(sender)
    }

    func selectLastTabViewItem(_ sender: AnyObject?) {
        tabView.selectLastTabViewItem(sender)
    }

    func selectNextTabViewItem(_ sender: AnyObject?) {
        tabView.selectNextTabViewItem(sender)
    }

    func selectPreviousTabViewItem(_ sender: AnyObject?) {
        tabView.selectPreviousTabViewItem(sender)
    }

    func selectTabViewItem(_ tabViewItem: NSTabViewItem?) {
        tabView.selectTabViewItem(tabViewItem)
    }

    func selectTabViewItem(at index: Int) {
        tabView.selectTabViewItem(at: index)
    }

    func selectTabViewItem(withIdentifier identifier: AnyObject) {
        tabView.selectTabViewItem(withIdentifier: identifier)
    }

    func takeSelectedTabViewItemFromSender(_ sender: AnyObject?) {
        tabView.takeSelectedTabViewItemFromSender(sender)
    }
}
