//
//  Downloader.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-12-27.
//

import Foundation
import AppKit

//class ConnectionManager: NSObject {
//    static let sharedInstance = ConnectionManager()

class DownloaderProgress: NSObject {
    static let shardInstance = DownloaderProgress()
    @objc dynamic var isFinished: Bool = false
    @objc dynamic var progress: Double = 0.0
    @objc dynamic var filePath: URL?
}

class FilesDownloader: NSObject, URLSessionDownloadDelegate {
    private var observation: NSKeyValueObservation?
    private var toURL: URL?
    func download(from url: URL, tourl: URL) {
        self.toURL = tourl
        DownloaderProgress.shardInstance.filePath = toURL
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: url.absoluteString) // use this identifier to resume download after app restart
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            if DownloaderProgress.shardInstance.isFinished {
                print("finished")
                self.observation?.invalidate()
                DownloaderProgress.shardInstance.isFinished = false
            }
            print("progress: ", progress.fractionCompleted * 100)
            DownloaderProgress.shardInstance.progress = (progress.fractionCompleted * 100)
        }
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: toURL!)
        } catch (let writeError) {
            print("Error creating a file \(location) : \(writeError)")
        }
        DownloaderProgress.shardInstance.isFinished = true
    }
}
