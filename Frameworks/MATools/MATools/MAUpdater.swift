//
//  MAUpdater.swift
//  MAUpdater
//
//  Created by Ashwin Paudel on 2021-12-30.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

public class MAUpdater {
    public var lastestVersion: String = ""
    public var updatesNeeded: Bool
    public let versionURL = "https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/version.txt"
    
    public init() {
        // Get the lastest version
        lastestVersion = MAURL(versionURL).contents().removeWhitespace
        
        // Check if updates are avalible
        if lastestVersion == MA_APP_VERSION  {
            updatesNeeded = false
        } else {
            updatesNeeded = true
        }
    }
    
    public func checkForUpdates() {
        print("CHECKING FOR UPDATES...")
        if updatesNeeded == true {
            MAUpdateAlertViewController.present()
            print("UPDATES ARE AVALIBLE")
        } else {
            print("NO UPDATES AVALIBLE")
        }
    }
    
}


open class Downloader {
    open func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
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

