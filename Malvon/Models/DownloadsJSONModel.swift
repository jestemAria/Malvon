//
//  DownloadsJSONModel.swift
//  Malvon
//
//  Created by Ashwin Paudel on 2021-12-28.
//  Copyright © 2021 Ashwin Paudel. All rights reserved.
//

import Foundation

struct MADownloadElement: Codable {
    let fileName, date, fileLocation: String
    let fileAddress: String
}
