//
//  AppProperties.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-31.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Foundation

public struct AppProperties {
    var showsTabBar: Bool

    private let defaults = UserDefaults.standard

    public init() {
        showsTabBar = defaults.bool(forKey: "MA_APP_PROPERTIES_showsTabBar")
    }

    func set() {
        defaults.set(showsTabBar, forKey: "MA_APP_PROPERTIES_showsTabBar")
    }
}
