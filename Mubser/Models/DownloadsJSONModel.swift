//
//  DownloadsJSONModel.swift
//  Mubser
//
//  Created by Ashwin Paudel on 2021-12-28.
//

import Foundation

struct MubDownloadElement: Codable {
    let fileName, date, fileLocation: String
    let fileAddress: String
}
