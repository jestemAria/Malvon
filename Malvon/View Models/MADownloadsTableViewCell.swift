//
//  MADownloadsTableViewCell.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MADownloadsTableViewCell: NSTableCellView {
    
    @IBOutlet weak var MAFileIcon: NSImageView!
    @IBOutlet weak var MAFileName: NSTextField!
    @IBOutlet weak var MALocation: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.cornerRadius = 15
        // Drawing code here.
    }
    
}
