//
//  Extension+String.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

extension String {
    public var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    public var encodeToURL: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    public var removeHTTP: String {
        URL(string: self)!.host ?? "about:blank"
    }
    
    public var removeWhitespace: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func string(_ after: String) -> String {
        if let range = self.range(of: after) {
            let afterString = self[range.upperBound...]
            return String(afterString)
        } else {
            return ""
        }
    }
    
    public var fileName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    public var fileExtension: String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
