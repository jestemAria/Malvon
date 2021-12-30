//
//  MATabsTableViewCell.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MATabsTableViewCell: NSTableCellView {
    
    @IBOutlet weak var TabIcon: NSImageView!
    @IBOutlet weak var TabTitle: NSTextField!
    @IBOutlet weak var TabCloseButton: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.cornerRadius = 15
        // Drawing code here.
    }
    
}
