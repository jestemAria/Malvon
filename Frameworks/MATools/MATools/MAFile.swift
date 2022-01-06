//
//  MAFile.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

public class MAFile {
    let path: String
    
    // MARK: - Initilizers

    public init(path: String) {
        self.path = path
    }
    
    public init(name: String, extension: String) {
        self.path = Bundle.main.path(forResource: name, ofType: `extension`)!
    }
    
    public init(path: URL) {
        self.path = path.path
    }
    
    // MARK: - Public Functions

    @discardableResult
    public func unzip(destination: String) -> Bool {
        _unzip(path: path, destination: destination)
    }
    
    @discardableResult
    public func unzip(destination: URL) -> Bool {
        _unzip(path: path, destination: destination.path)
    }
    
    public func exists() -> Bool {
        _exists(path: path)
    }
    
    public func read() -> String {
        _read(path: path)
    }
    
    public func write(_ contents: String) {
        _write(path: path, contents: contents)
    }
    
    /// Create a file if it doesn't exist
    public func createFileIfNotExists(contents: String) {
        if !exists() {
            write(contents)
        }
    }
    
    // MARK: - Private Functions

    private func _unzip(path: String, destination: String) -> Bool {
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
        let result = String(data: resultData, encoding: .utf8) ?? ""
        print(result)
        
        return process.terminationStatus <= 1
    }
    
    private func _exists(path: String) -> Bool {
        let filePath = path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    private func _read(path: String) -> String {
        var contents = ""
        do {
            contents = try String(contentsOfFile: path)
        } catch {
            print("Error: [Reading File]: \(error.localizedDescription)")
        }
        return contents
    }
    
    private func _write(path: String, contents: String) {
        do {
            try contents.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            print("Error: [Writing File]: \(error.localizedDescription)")
        }
    }
}
