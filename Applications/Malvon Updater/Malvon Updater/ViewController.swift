//
//  ViewController.swift
//  Malvon Updater
//
//  Created by Ashwin Paudel on 2021-12-30.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    
    // Parameters
    public let newFeatures = URL(string: "https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/update_feature_list.txt")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = newFeatures.contents
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nowNow(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func installPressed(_ sender: Any) {
        let newestVersion = URL(string: "https://raw.githubusercontent.com/Ashwin-Paudel/Malvon/main/Malvon/Resources/version.txt")!.contents.removeWhitespace
        let newAppFile = URL(string: "https://github.com/Ashwin-Paudel/Malvon/releases/download/v\(newestVersion)/Malvon.\(newestVersion).zip")!
        let downloadLocation = dataDirectory()!.appendingPathComponent("Malvon.\(newestVersion).zip")
        
        print(downloadLocation)
        
        // 1. Download the zip file
        Downloader.loadFileAsync(url: newAppFile, dest: downloadLocation) { [self] path, error in
            print("Downloaded File \(path!)")
            unzip(path: downloadLocation.path, destination: dataDirectory()!.appendingPathComponent("Output").path)
            do {
                if FileManager.default.fileExists(atPath: "/Applications/Malvon.app") {
                    try FileManager.default.removeItem(atPath: "/Applications/Malvon.app")
                }
                try FileManager.default.moveItem(atPath: dataDirectory()!.appendingPathComponent("Output/Malvon.app").path, toPath: "/Applications/Malvon.app")
                
                // Launch Malvon and quit the updater
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["/Applications/Malvon.app"]
                task.launch()
                exit(0)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        // 2. Unzip the file
        
        //        FileDownloader.loadFileAsync(url: newAppFile) { [self] (path, error) in
        //            if let error = error {
        //                print("ERRRRRR:::::", error.localizedDescription)
        //            }
        ////            do
        //            try? FileManager.default.moveItem(atPath: path!, toPath: downloadLocation.path)
        //// 2. Unzip the file
        //
        //        }
    }
    
    public func dataDirectory() -> URL? {
        do {
            let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
            let folder = applicationSupportFolderURL.appendingPathComponent("\(appName)/data", isDirectory: true)
            if !FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            }
            return folder
        } catch {}
        return nil
    }
    
    @discardableResult
    func unzip(path: String, destination: String) -> Bool {
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
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension URL {
    var contents: String {
        do {
            return try String(contentsOf: self)
        } catch {
            print("Error \(error.localizedDescription)")
        }
        return ""
    }
}

extension String {
    var removeWhitespace: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Downloader

// https://stackoverflow.com/a/56580009
enum Downloader {
    static func loadFileAsync(url: URL, dest: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let destinationUrl = dest
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                } else {
                                    completion(destinationUrl.path, error)
                                }
                            } else {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                } else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
