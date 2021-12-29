//
//  MASearchField.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-27.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MASearchField: NSSearchField {
    
    //    fileprivate var trackingArea: NSTrackingArea!
    //
    //
    //    required init?(coder: NSCoder) {
    //        super.init(coder: coder)
    //        self.createTrackingArea()
    //    }
    //
    //    override init(frame frameRect: NSRect) {
    //        super.init(frame: frameRect)
    //        self.createTrackingArea()
    //    }
    //
    //    func createTrackingArea() {
    //        if self.trackingArea != nil {
    //            self.removeTrackingArea(self.trackingArea!)
    //        }
    //        let circleRect = self.bounds
    //        let flag = NSTrackingArea.Options.mouseEnteredAndExited.rawValue + NSTrackingArea.Options.activeInActiveApp.rawValue
    //        self.trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingArea.Options(rawValue: flag), owner: self, userInfo: nil)
    //        self.addTrackingArea(self.trackingArea)
    //    }
    //
    //    override func mouseDown(with event: NSEvent) {
    //        if let editor = currentEditor() {
    //            editor.selectAll(self)
    //        }
    //        self.stringValue = GlobalVariables.currentWebsite
    //    }
    //
    //    override func mouseEntered(with event: NSEvent) {
    //        self.stringValue = GlobalVariables.currentWebsite
    //    }
    //
    //    override func mouseExited(with event: NSEvent) {
    //        self.stringValue = GlobalVariables.currentWebsiteRemovedHTTP
    //    }
}
