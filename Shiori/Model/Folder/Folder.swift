//
//  Folder.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/11.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct Folder: Codable {
    let folderId: Int
    let userId: Int
    let name: String
    let contentCount: Int
    let contentList: [Int]?
    enum CodingKeys: String, CodingKey {
        case folderId = "folder_id"
        case userId = "user_id"
        case name
        case contentCount = "content_count"
        case contentList = "content_list"
    }
}
