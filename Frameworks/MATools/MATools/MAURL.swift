//
//  MAURL.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Foundation

public class MAURL {
    let url: URL
    public init(_ url: URL) {
        self.url = url
    }

    public init(_ url: String) {
        self.url = URL(string: url)!
    }

    public func fix() -> URL {
        var newURL = ""

        if url.isFileURL || (url.host != nil && url.scheme != nil) {
            return url
        }
        if url.scheme == nil {
            newURL += "https://"
        }
        if let host = url.host, host.contains("www") {
            newURL += "www.\(url.host!)"
        }

        newURL += url.path
        newURL += url.query ?? ""
        return URL(string: newURL)!
    }

    public func contents() -> String {
        do {
            return try String(contentsOf: url)
        } catch {
            print("Error \(error.localizedDescription)")
        }
        return ""
    }
}

extension URL {
    var parentDirectory: URL? {
        return (try? resourceValues(forKeys: [.parentDirectoryURLKey]))?.parentDirectory
    }
}
