//
//  MATabsTableViewCell.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MATabsTableViewCell: NSTableCellView {
    @IBOutlet var TabIcon: NSImageView!
    @IBOutlet var TabTitle: NSTextField!
    @IBOutlet var TabCloseButton: NSButton!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.cornerRadius = 15
        // Drawing code here.
    }
}
