//
//  MAUpdateAlertViewController.swift
//  MAUpdater
//
//  Created by Ashwin Paudel on 2021-12-30.
//

import Cocoa

class MAUpdateAlertViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    
    public let newFeatures = "https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/update_feature_list.txt"
    
    static func present() {
        var bundle: Bundle? {
            let bundleId = "com.ashwin.MATools"
            return Bundle(identifier: bundleId)
        }
        
        let window = NSWindow(contentViewController: MAUpdateAlertViewController(nibName: "MAUpdateAlertViewController", bundle: bundle))
        
        window.title = "Updater"
        window.makeKeyAndOrderFront(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textView.string = MAURL(newFeatures).contents()
    }
    
    @IBAction func installPressed(_ sender: Any) {
        let updater = MAUpdater()
        let downloadURL = "https://github.com/Ashwin-Paudel/Malvon/releases/download/\(updater.lastestVersion)/Malvon.\(updater.lastestVersion).zip"
        let downloadLocation = MAPaths(.data).get()?.appendingPathComponent("Malvon.\(updater.lastestVersion).zip")
        Downloader().load(url: URL(string: downloadURL)!, to: downloadLocation!) {}
        
        MAFile(path: downloadLocation!).unzip(destination: MAPaths(.data).get()!.appendingPathComponent("Output"))
        do {
            let newAppLocation = MAPaths(.data).get()?.appendingPathComponent("Output/Malvon.app")
            let applications = "/Applications/Malvon.app"
            print(applications)
            if MAFile(path: applications).exists() {
                try FileManager.default.removeItem(atPath: applications)
            }
            try FileManager.default.moveItem(atPath: newAppLocation!.path, toPath: applications)
        } catch {
            print("Error:::: \(error.localizedDescription)")
        }
    }
    
    @IBAction func notNowPressed(_ sender: Any) {
        self.view.window?.close()
    }
    
}
