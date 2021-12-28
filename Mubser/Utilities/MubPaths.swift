//
//  MubPaths.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-12-28.
//

import Cocoa

public struct MubPaths {
    static func dataDirectory() -> URL? {
        do {
            let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
            let folder = applicationSupportFolderURL.appendingPathComponent("\(appName)/data", isDirectory: true)
            if !FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            }
            return folder
        } catch {}
        return nil
    }
}
