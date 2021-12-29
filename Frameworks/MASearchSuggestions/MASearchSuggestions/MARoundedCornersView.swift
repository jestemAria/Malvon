//
//  MARoundedCornersView.swift
//  MASearchSuggestions
//
//  Created by Ashwin Paudel on 2021-01-04.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MARoundedCornersView: NSView {
    var cornerRadius: CGFloat = 0.0
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        cornerRadius = 3.0
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let borderPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
        NSColor.windowBackgroundColor.setFill()
        borderPath.fill()
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override var allowsVibrancy: Bool {
        return true
    }
}
