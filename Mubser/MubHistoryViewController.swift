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
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        historyJSON = parseJSON()!.reversed()

        tableView.reloadData()
    }

    @IBAction func clearHistory(_ sender: Any) {}

    // MARK: - Table View

    func numberOfRows(in tableView: NSTableView) -> Int {
        return historyJSON.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }

        if (tableColumn?.identifier)!.rawValue == "historyWebsite" {
            cell.textField?.stringValue = historyJSON[row].website
        } else if (tableColumn?.identifier)!.rawValue == "historyAddress" {
            cell.textField?.stringValue = historyJSON[row].address
        }

        return cell
    }

    // MARK: - History Items

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
