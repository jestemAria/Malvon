//
//  HoverButton.swift
//  Mubser
//
//  Created by Ashwin Paudel on 30/11/2021.
//

// Code From: https://github.com/fancymax/HoverButton

import Cocoa

class HoverButton: NSButton {
    var backgroundColor: NSColor?
    var hoveredBackgroundColor: NSColor?
    var pressedBackgroundColor: NSColor?
    
    var changeTint: Bool = false
    
    fileprivate var hovered: Bool = false
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    func commonInit() {
        self.wantsLayer = true
        self.createTrackingArea()
        self.hovered = false
        self.hoveredBackgroundColor = NSColor.selectedTextBackgroundColor
        self.pressedBackgroundColor = NSColor.selectedTextBackgroundColor
        self.backgroundColor = NSColor.clear
    }
    
    fileprivate var trackingArea: NSTrackingArea!
    func createTrackingArea() {
        if self.trackingArea != nil {
            self.removeTrackingArea(self.trackingArea!)
        }
        let circleRect = self.bounds
        let flag = NSTrackingArea.Options.mouseEnteredAndExited.rawValue + NSTrackingArea.Options.activeInActiveApp.rawValue
        self.trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingArea.Options(rawValue: flag), owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    
    public var cornerRadius: CGFloat = 0.5
    
    override func updateLayer() {
        if self.hovered, self.isEnabled {
            if self.cell!.isHighlighted {
                self.layer?.cornerRadius = self.cornerRadius
                
                if changeTint {
                    self.contentTintColor = .yellow
                } else {
                    self.layer?.backgroundColor = self.pressedBackgroundColor?.cgColor
                }
            } else {
                self.layer?.cornerRadius = self.cornerRadius
                
                if changeTint {
                    self.contentTintColor = .yellow
                } else {
                    self.layer?.backgroundColor = self.hoveredBackgroundColor?.cgColor
                }
            }
        } else {
            
            if changeTint {
                self.contentTintColor = .labelColor
            } else {
                self.layer?.backgroundColor = self.backgroundColor?.cgColor
            }
            self.layer?.borderWidth = 0
        }
    }
}
