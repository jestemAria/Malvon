//
//  MADownloadsTableViewCell.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MADownloadsTableViewCell: NSTableCellView {
    @IBOutlet var MAFileIcon: NSImageView!
    @IBOutlet var MAFileName: NSTextField!
    @IBOutlet var MALocation: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.cornerRadius = 15
        // Drawing code here.
    }
}
