//
//  MubTabCloseButton.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/MubTabView

import Cocoa

class MubTabCloseButton: MubHoverButton {
    private static let closeImage = NSImage(named: NSImage.stopProgressTemplateName)?
        .scaleToSize(CGSize(width: 8, height: 8))
    var roundCornerRadius: CGFloat = 2

    func setupButton() {
        self.setButtonType(.momentaryPushIn)
        self.bezelStyle = .shadowlessSquare
        self.image = MubTabCloseButton.closeImage
        self.isBordered = false
        self.imagePosition = .imageOnly
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: self.bounds, xRadius: roundCornerRadius, yRadius: roundCornerRadius)
        if hovered {
            self.hoverBackgroundColor?.setFill()
        } else {
            self.backgroundColor.setFill()
        }
        path.fill()
        super.draw(dirtyRect)
    }
}
