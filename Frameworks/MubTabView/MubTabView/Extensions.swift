//
//  Extensions.swift
//  MubTabView
//
//  Created by Ashwin Paudel on 01/12/2021.
//

// Code from: https://github.com/robin/LYTabView

import Cocoa

public extension NSImage {
    func scaleToSize(_ size: CGSize) -> NSImage {
        let scaledImage = NSImage(size: size)
        let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: size)
        scaledImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: rect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
        scaledImage.unlockFocus()
        return scaledImage
    }
}

extension NSStackView {
    func insertView(_ aView: NSView, atIndex index: Int,
                    inGravity gravity: NSStackView.Gravity,
                    animated: Bool, completionHandler: (() -> Void)?)
    {
        self.insertView(aView, at: index, in: gravity)
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
            }, completionHandler: completionHandler)
        }
    }

    func addView(_ aView: NSView,
                 inGravity gravity: NSStackView.Gravity,
                 animated: Bool, completionHandler: (() -> Void)?)
    {
        self.addView(aView, in: gravity)
        if animated {
            aView.setFrameOrigin(NSPoint(x: self.frame.maxX, y: self.frame.origin.y))
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
            }, completionHandler: completionHandler)
        }
    }

    func removeView(_ aView: NSView, animated: Bool, completionHandler: (() -> Void)?) {
        self.removeView(aView)
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
            }, completionHandler: completionHandler)
        }
    }
}

extension NSAnimatablePropertyContainer {
    func animatorOrNot(_ needAnimator: Bool = true) -> Self {
        if needAnimator {
            return self.animator()
        }
        return self
    }
}
