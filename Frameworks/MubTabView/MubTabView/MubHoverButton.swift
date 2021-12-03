//
//  MubHoverButton.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/LYTabView

import Cocoa

class MubHoverButton: NSButton {
    var hoverBackgroundColor: NSColor?
    var backgroundColor = NSColor.clear

    var hovered = false
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.enabledDuringMouseDrag, .mouseEnteredAndExited, .activeAlways]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        if self.hovered {
            return
        }
        self.hovered = true
        needsDisplay = true
    }

    override func mouseExited(with theEvent: NSEvent) {
        if !self.hovered {
            return
        }
        self.hovered = false
        needsDisplay = true
    }
}
