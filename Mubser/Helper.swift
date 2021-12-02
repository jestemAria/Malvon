//
//  Helper.swift
//  Mubser
//
//  Created by Ashwin Paudel on 01/12/2021.
//

import Cocoa

// MARK: - File

func readFile(path: URL) -> String {
    var contents = ""
    do {
        contents = try String(contentsOfFile: path.relativePath)
    } catch {
        print("Error: [Reading File]: \(error.localizedDescription)")
    }
    return contents
}

func readFile(fileName: String, extension: String) -> String {
    var contents = ""
    do {
        contents = try String(contentsOfFile: Bundle.main.path(forResource: fileName, ofType: `extension`)!)
    } catch {
        print("Error: [Reading File]: \(error.localizedDescription)")
    }
    return contents
}

// MARK: - Paths

public func mubDataDir() -> URL? {
    do {
        let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // swiftlint:disable force_cast
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        let folder = applicationSupportFolderURL.appendingPathComponent("\(appName)/data", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        return folder
    } catch {}
    return nil
}
