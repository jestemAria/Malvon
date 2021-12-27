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

// Writing

func writeFile(contents: String, path: URL) {
    do {
        try contents.write(to: path, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Error: [Writing File]: \(error.localizedDescription)")
    }
}

func writeFile(contents: String, fileName: String, extension: String) {
    let path = URL(string: "file://" + Bundle.main.path(forResource: fileName, ofType: `extension`)!)!
    do {
        try contents.write(to: path, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Error: [Writing File]: \(error.localizedDescription)")
    }
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

// MARK: - Extensions

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
        let url = URL(string: self)!
        let string1 = String(url.absoluteString.dropFirst((url.scheme?.count ?? -3) + 3))
        
        return url.host!
    }
    
    var removeWhitespace: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
