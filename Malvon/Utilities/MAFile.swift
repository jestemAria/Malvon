//
//  MAFile.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

public struct MAFile {
    
    @discardableResult
    static func unzip(path: String, destination: String) -> Bool {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", path, "-d", destination]
        process.standardOutput = pipe
        
        do {
            try process.run()
        } catch {
            return false
        }
        
        let resultData = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String (data: resultData, encoding: .utf8) ?? ""
        print(result)
        
        return process.terminationStatus <= 1
    }
    
    // MARK: - File Status
    
    static func exists(path: URL) -> Bool {
        let filePath = path.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    static func exists(path: String) -> Bool {
        let filePath = URL(string: path)!.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Reading
    
    static func read(path: URL) -> String {
        var contents = ""
        do {
            contents = try String(contentsOfFile: path.relativePath)
        } catch {
            print("Error: [Reading File]: \(error.localizedDescription)")
        }
        return contents
    }
    
    static func read(name: String, extension: String) -> String {
        var contents = ""
        do {
            contents = try String(contentsOfFile: Bundle.main.path(forResource: name, ofType: `extension`)!)
        } catch {
            print("Error: [Reading File]: \(error.localizedDescription)")
        }
        return contents
    }
    
    // MARK: - Writing
    
    static func write(contents: String, path: URL) {
        do {
            try contents.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error: [Writing File]: \(error.localizedDescription)")
        }
    }
    
    static func write(contents: String, name: String, extension: String) {
        let path = URL(string: "file://" + Bundle.main.path(forResource: name, ofType: `extension`)!)!
        do {
            try contents.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error: [Writing File]: \(error.localizedDescription)")
        }
    }
}
