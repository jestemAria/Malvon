//
//  MubTabViewController.swift
//  Mubser
//
//  Created by Ashwin Paudel on 05/12/2021.
//

import Cocoa

class MubTabViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 100
    }
    
}
