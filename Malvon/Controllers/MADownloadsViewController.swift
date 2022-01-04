//
//  MADownloadsViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MATools

class MADownloadsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    // The TableView that will display the items
    @IBOutlet var tableView: NSTableView!
    
    // The SearchField
    @IBOutlet var searchField: NSSearchField!
    
    // All the items in the download history
    var downloadItems = [MADownloadElement]()
    
    // The Path to the JSON File
    static let path = MAPaths(.data).get()?.appendingPathComponent("downloads.json")
    
    // The menu item for the TableView
    lazy var tableViewMenu: NSMenu = {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Show In Finder", action: #selector(showInFinder), keyEquivalent: "")
        menu.addItem(withTitle: "Copy Download Address", action: #selector(copyDownloadAddress), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Remove from Downloads", action: #selector(removeFromDownloads), keyEquivalent: "")
        
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Read the json file
        downloadItems = parseItems()
        
        // Configure the table view
        configureTableView()
    }
    
    private func configureTableView() {
        // Configure the table view menu
        tableView.menu = tableViewMenu
        
        // Configure the double click
        tableView.doubleAction = #selector(showInFinder)
        
        // Configure the delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Reload the data
        tableView.reloadData()
    }
    
    // MARK: - Menu Actions
    
    @objc func showInFinder() {}
    
    @objc func copyDownloadAddress() {}
    
    @objc func removeFromDownloads() {}
    
    // MARK: - TableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // Return the number of items in the downloadItems
        return downloadItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Get an instance of the cell
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        // Check if it's the FileName cell
        if tableColumn!.identifier.rawValue == "downloadsViewControlerKeypath_FILENAME" {
            cell.textField?.stringValue = downloadItems[row].fileName
        
            // Check if it's the FileLocation cell
        } else if tableColumn!.identifier.rawValue == "downloadsViewControlerKeypath_FILELOCATION" {
            cell.textField?.stringValue = downloadItems[row].fileLocation
        }
        
        // Return the cell
        return cell
    }
    
    // MARK: - JSON
    
    func refreshTableView() {
        // Update the downloadItems
        downloadItems = parseItems()
        // Reload the tableView
        tableView.reloadData()
    }
    
    func parseItems() -> [MADownloadElement] {
        // Get an instace of the MAFile
        let file = MAFile(path: MAHistoryViewController.path!)
        
        // Create a file if it doesn't exist
        file.createFileIfNotExists(contents: "[]")
        
        // Read the file contents
        let fileContents = file.read()

        // Decode the JSON
        let decodedJSON = try! JSONDecoder().decode([MADownloadElement].self, from: fileContents.data(using: .utf8)!)
        
        // Return the decoded JSON
        return decodedJSON
    }
}
