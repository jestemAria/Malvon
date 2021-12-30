//
//  MAUpdater.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-29.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

public class MAUpdater {
    private var lastestVersion: String = ""
    private var updatesNeeded: Bool
    private let versionURL = "https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/version.txt"
    
    public init() {
        // Get the lastest version
        if let url = URL(string: versionURL) {
            do {
                lastestVersion = try String(contentsOf: url).removeWhitespace
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
        
        // Check if updates are avalible
        if lastestVersion != Properties.currentVersion {
            updatesNeeded = false
        } else {
            updatesNeeded = true
        }
    }
    
    private func askForPermissions() -> Bool {
        let alert = NSAlert()
        alert.messageText = "New updates avalible!"
        alert.informativeText = "Would you like to install the updates?"
        
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            return true
        } else {
            return false
        }
    }
    
    public func checkForUpdates() {
        let downloadURL = "https://github.com/Ashwin-Paudel/Malvon/releases/download/\(lastestVersion)/Malvon.\(lastestVersion).zip"
        let downloadLocation = MAPaths.dataDirectory()?.appendingPathComponent("Malvon.\(lastestVersion).zip")
        
        
        if updatesNeeded == true && askForPermissions() == true {
            Downloader().load(url: URL(string: downloadURL)!, to: downloadLocation!) {}
            
            MAFile.unzip(path: downloadLocation!.path, destination: MAPaths.dataDirectory()!.appendingPathComponent("Output").path)
            
            do {
                let newAppLocation = MAPaths.dataDirectory()!.appendingPathComponent("Output/Malvon.app")
                let applications = "/Applications/Malvon.app"
                print(applications)
                if MAFile.exists(path: applications) {
                    try FileManager.default.removeItem(atPath: applications)
                }
                try FileManager.default.moveItem(atPath: newAppLocation.path, toPath: applications)
            } catch {
                print("Error:::: \(error.localizedDescription)")
            }
        }
        
    }
    
}


private class Downloader {
    public func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Failure: \(error!.localizedDescription)")
            }
        }
        task.resume()
    }
}
