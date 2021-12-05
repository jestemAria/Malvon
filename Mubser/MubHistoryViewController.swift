//
//  MubHistoryViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 01/12/2021.
//

import Cocoa

class MubHistoryViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    var historyJSON = [MubHistoryElement]()
    static let path = mubDataDir()?.appendingPathComponent("history.json")

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
        var newHistoryJSON: [MubHistoryElement] = historyJSON
        let url = newHistoryJSON[tableView.clickedRow].address

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
        NSPasteboard.general.string(forType: .string)
        view.window?.close()
    }

    @IBAction func deleteItem(_ sender: Any) {
        var newHistoryJSON: [MubHistoryElement] = historyJSON
        newHistoryJSON.reverse()
        newHistoryJSON.remove(at: tableView.clickedRow)

        do {
            let data = try JSONEncoder().encode(newHistoryJSON)
            try data.write(to: MubHistoryViewController.path!)
        } catch {
            print(error.localizedDescription)
        }

        refreshTableView()
    }

    @IBAction func clearHistory(_ sender: Any) {
        let emptyHistoryJSON = [MubHistoryElement]()

        do {
            let data = try JSONEncoder().encode(emptyHistoryJSON)
            try data.write(to: MubHistoryViewController.path!)
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

    // MARK: - History Items

    func refreshTableView() {
        historyJSON = parseJSON()!
        tableView.reloadData()
    }

    func parseJSON() -> [MubHistoryElement]? {
        let fileContents = readFile(path: MubHistoryViewController.path!)
        let decodedJSON = try? JSONDecoder().decode([MubHistoryElement].self, from: fileContents.data(using: .utf8)!)

        return decodedJSON
    }
}

struct MubHistoryElement: Codable {
    let website: String
    let address: String
}
