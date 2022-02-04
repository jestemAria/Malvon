//
//  MATabViewConfiguration.swift
//  MATabView
//
//  Created by Ashwin Paudel on 2022-02-02.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

public struct MATabViewConfiguration {
    // Light
    var lightTabColor: NSColor = .white
    var lightTabBorderColor: NSColor = .black
    var lightTabBackgroundColor: NSColor = .white

    // Dark
    var darkTabColor: NSColor = .black
    var darkTabBorderColor: NSColor = .lightGray
    var darkTabBackgroundColor: NSColor = .black

    // Tab Dimensions
    var tabHeight: CGFloat = 30.0
    var tabWidth: CGFloat = 225.0
}
