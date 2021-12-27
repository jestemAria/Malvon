//
//  MubWebViewDownloadingViewController.swift
//  MubWebView
//
//  Created by Ashwin Paudel on 2021-12-27.
//

import Cocoa

class MubWebViewDownloadingViewController: NSViewController {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var progressLabel: NSTextField!
    
    private var token: NSKeyValueObservation?
    private var token1: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("elwaifjemlfkm")
        
        token1 = DownloaderProgress.shardInstance.observe(\.isFinished, changeHandler: { _, _ in
            print("finished")
            DispatchQueue.main.async {
                self.token1?.invalidate()
                DownloaderProgress.shardInstance.isFinished = false
                self.view.window?.close()
                
                
                
                NSWorkspace.shared.selectFile(DownloaderProgress.shardInstance.filePath?.absoluteString, inFileViewerRootedAtPath: "")
            }
            
        })
        
        
        token = DownloaderProgress.shardInstance.observe(\.progress, changeHandler: { _, _ in
            DispatchQueue.main.async {
                self.progressIndicator?.doubleValue = DownloaderProgress.shardInstance.progress
                self.progressLabel.stringValue = String(Int(DownloaderProgress.shardInstance.progress)) + "%"
            }
        })
        
    }
}
