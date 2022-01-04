//
//  Extension+String.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

public extension String {
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
        URL(string: self)!.host ?? "about:blank"
    }
    
    var removeWhitespace: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func string(_ after: String) -> String {
        if let range = self.range(of: after) {
            let afterString = self[range.upperBound...]
            return String(afterString)
        } else {
            return ""
        }
    }
    
    var fileName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    var fileExtension: String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
