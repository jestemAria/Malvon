//
//  MATabViewItem.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-01-06.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

open class MATabViewItem: NSObject {
    open var view: NSView?
    open var title: String?
    open var tabView: MATabView?
    open var index: Int?
    open var image: NSImage?

    public convenience init(view: NSView) {
        self.init()
        self.view = view
    }

    override public init() {}
}
