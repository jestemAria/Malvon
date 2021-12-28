//
//  Extension+String.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-12-28.
//

import Cocoa

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    var encodeToURL: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var removeHTTP: String {
        URL(string: self)!.host!
    }
    
    var removeWhitespace: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
