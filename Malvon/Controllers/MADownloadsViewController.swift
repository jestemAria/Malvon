//
//  MADownloadsViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Cocoa

class MADownloadsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    var downloadJSON = [MADownloadElement]()
    static let path = MAPaths.dataDirectory()?.appendingPathComponent("downloads.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFileIfNotExists()
        downloadJSON = parseJSON()!
        
        setUpMenuItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
    func setUpMenuItems() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open", action: #selector(openURL), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Copy File Path", action: #selector(copyLocation), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Copy Download URL", action: #selector(copyAddress), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Remove From Download", action: #selector(deleteItem), keyEquivalent: ""))
        tableView.menu = menu
        tableView.doubleAction = #selector(openURL)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return downloadJSON.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DownloadsItemCell"), owner: self) as? MADownloadsTableViewCell else { return nil }
        
        cell.MAFileName.stringValue = downloadJSON[row].fileName
        cell.MALocation.stringValue = downloadJSON[row].fileLocation
        
        return cell
    }
    
    // MARK: - Download Items
    
    func refreshTableView() {
        downloadJSON = parseJSON()!
        tableView.reloadData()
    }
    
    func parseJSON() -> [MADownloadElement]? {
        let fileContents = MAFile.read(path: MADownloadsViewController.path!)
        let decodedJSON = try? JSONDecoder().decode([MADownloadElement].self, from: fileContents.data(using: .utf8)!)
        
        return decodedJSON
    }
    
    func createFileIfNotExists() {
        if let pathComponent = MAHistoryViewController.path {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
            } else {
                let str = "[]"
                do {
                    try str.write(to: MADownloadsViewController.path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        } else {
        }
    }
    
    // MARK: - Buttons
    
    @IBAction func closeButton(_ sender: Any) {
        self.view.window?.close()
    }
    
    
    @IBAction func clearDownload(_ sender: Any) {
        let emptyDownloadJSON = [MADownloadElement]()
        
        do {
            let data = try JSONEncoder().encode(emptyDownloadJSON)
            try data.write(to: MADownloadsViewController.path!)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
        refreshTableView()
    }
    
    // MARK: - TableView Menu Actions
    
    @objc func openURL() {
        // TODO: Handle Custom URLS
    }
    
    @objc func copyLocation() {
        let newDownloadJSON: [MADownloadElement] = downloadJSON
        let url = newDownloadJSON[tableView.clickedRow].fileLocation
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
        NSPasteboard.general.string(forType: .string)
        view.window?.close()
    }
    
    @objc func copyAddress() {
        let newDownloadJSON: [MADownloadElement] = downloadJSON
        let url = newDownloadJSON[tableView.clickedRow].fileAddress
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
        NSPasteboard.general.string(forType: .string)
        view.window?.close()
    }
    
    @objc func deleteItem() {
        var newDownloadJSON: [MADownloadElement] = downloadJSON
        newDownloadJSON.reverse()
        newDownloadJSON.remove(at: tableView.clickedRow)
        
        do {
            let data = try JSONEncoder().encode(newDownloadJSON)
            try data.write(to: MADownloadsViewController.path!)
        } catch {
            print(error.localizedDescription)
        }
        
        refreshTableView()
    }
    
}
