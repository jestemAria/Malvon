//
//  MATab.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

open class MATab: NSObject {
    open var view: NSView
    open var title: String
    open var icon: NSImage
    open var isSelectedTab = false

    // The position of the tab
    public var position: Int = 0

    public init(view: NSView) {
        self.view = view
        self.title = ""
        self.icon = NSImage()
    }

    public init(view: NSView, title: String) {
        self.view = view
        self.title = title
        self.icon = NSImage()
    }

    public init(view: NSView, title: String, icon: NSImage) {
        self.view = view
        self.title = title
        self.icon = icon
    }
}
