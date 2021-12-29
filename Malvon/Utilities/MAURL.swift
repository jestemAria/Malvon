//
//  MAURL.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Foundation

public struct MAURL {
    static func fixURL(url: URL) -> URL {
        var newURL = ""
        
        if url.scheme == nil {
            newURL += "https://"
        } else if !url.host!.contains("www") {
            newURL += "www.\(url.host!)"
        }
        newURL += url.path
        newURL += url.query ?? ""
        return URL(string: newURL)!
    }
}
