//
//  MAHistoryViewController.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-01.
//  Copyright © 2021-2022 Ashwin Paudel. All rights reserved.
//

import Cocoa
import MATools

class MAHistoryViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    var historyJSON = [MAHistoryElement]()
    static let path = MAPaths(.data).get()?.appendingPathComponent("history.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyJSON = parseJSON()!
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open", action: #selector(openURL), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Copy", action: #selector(copyURL), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Remove From History", action: #selector(deleteItem), keyEquivalent: ""))
        tableView.menu = menu
        tableView.doubleAction = #selector(openURL)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    // MARK: - TableView Actions
    
    @IBAction func openURL(_ sender: Any) {
        // TODO: Handle Custom URLS
    }
    
    @IBAction func copyURL(_ sender: Any) {
        let newHistoryJSON: [MAHistoryElement] = historyJSON
        let url = newHistoryJSON[tableView.clickedRow].address
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
        NSPasteboard.general.string(forType: .string)
        view.window?.close()
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        var newHistoryJSON: [MAHistoryElement] = historyJSON
        newHistoryJSON.reverse()
        newHistoryJSON.remove(at: tableView.clickedRow)
        
        do {
            let data = try JSONEncoder().encode(newHistoryJSON)
            try data.write(to: MAHistoryViewController.path!)
        } catch {
            print(error.localizedDescription)
        }
        
        refreshTableView()
    }
    
    @IBAction func clearHistory(_ sender: Any) {
        let emptyHistoryJSON = [MAHistoryElement]()
        
        do {
            let data = try JSONEncoder().encode(emptyHistoryJSON)
            try data.write(to: MAHistoryViewController.path!)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
        refreshTableView()
    }
    
    // MARK: - Table View
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return historyJSON.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        if (tableColumn?.identifier)!.rawValue == "historyWebsite" {
            cell.textField?.stringValue = historyJSON.reversed()[row].website
        } else if (tableColumn?.identifier)!.rawValue == "historyAddress" {
            cell.textField?.stringValue = historyJSON.reversed()[row].address
        }
        
        return cell
    }
    
    @IBAction func closeButton(_ sender: Any) {
        view.window?.close()
    }

    // MARK: - History Items
    
    func refreshTableView() {
        historyJSON = parseJSON()!
        tableView.reloadData()
    }
    
    func parseJSON() -> [MAHistoryElement]? {
        let fileContents = MAFile(path: MAHistoryViewController.path!).read()
        let decodedJSON = try? JSONDecoder().decode([MAHistoryElement].self, from: fileContents.data(using: .utf8)!)
        
        return decodedJSON
    }
}
