//
//  AppProperties.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-31.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Foundation

public struct AppProperties {
    var showsTabBar: Bool
    var showsBlackScreen: Bool
    
    private let defaults = UserDefaults.standard
    
    public init() {
        showsTabBar = defaults.bool(forKey: "MA_APP_PROPERTIES_showsTabBar")
        showsBlackScreen = defaults.bool(forKey: "MA_APP_PROPERTIES_showsBlackScreen")
    }
    
    func set() {
        defaults.set(showsTabBar, forKey: "MA_APP_PROPERTIES_showsTabBar")
        defaults.set(showsBlackScreen, forKey: "MA_APP_PROPERTIES_showsBlackScreen")
    }
}


