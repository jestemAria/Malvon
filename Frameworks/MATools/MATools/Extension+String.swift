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
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard detector != nil, self.count > 0 else { return false }
        if detector!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) > 0 {
            return true
        }
        return false
    }
    
    var encodeToURL: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var removeHTTP: String {
        URL(string: self)!.host ?? "about:blank"
    }
    
    var removeWhitespace: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func string(_ after: String) -> String {
        if let range = range(of: after) {
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
