//
//  MAWebViewDownloadingViewController.swift
//  MAWebView
//
//  Created by Ashwin Paudel on 2021-12-27.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MAWebViewDownloadingViewController: NSViewController {
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var progressLabel: NSTextField!
    
    @IBOutlet var percentageLabel: NSTextField!
    @IBOutlet var fileNameLabel: NSTextField!
    private var token: NSKeyValueObservation?
    private var token1: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        token1 = DownloaderProgress.shardInstance.observe(\.isFinished, changeHandler: { _, _ in
            DispatchQueue.main.async {
                self.token1?.invalidate()
                DownloaderProgress.shardInstance.isFinished = false
                NSWorkspace.shared.selectFile(DownloaderProgress.shardInstance.filePath?.absoluteString.replacingOccurrences(of: "file://", with: ""), inFileViewerRootedAtPath: "")
                self.view.window?.close()
            }
            
        })
        
        fileNameLabel.stringValue = DownloaderProgress.shardInstance.fileName ?? "???????.??"
        
        token = DownloaderProgress.shardInstance.observe(\.progress, changeHandler: { _, _ in
            DispatchQueue.main.async {
                self.progressIndicator?.doubleValue = DownloaderProgress.shardInstance.progress
                self.percentageLabel.stringValue = String(Int(DownloaderProgress.shardInstance.progress)) + "%"
                
                self.progressLabel.stringValue = "\(Units(bytes: Int64(DownloaderProgress.shardInstance.countOfBytesReceived)).getReadableUnit()) / \(Units(bytes: Int64(DownloaderProgress.shardInstance.countOfBytesExpectedToReceive)).getReadableUnit())"
            }
        })
    }
}
