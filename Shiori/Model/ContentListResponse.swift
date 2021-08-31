//
//  ContentListData.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/08/31.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct ContentListResponse: Codable {
    let meta: Meta
    let data: Data
}

struct Meta: Codable {
    let q: String?
    let per_page: Int?
    let page: Int?
    let nextPage: Int?
    let liked: Bool?
}

struct Data: Codable {
    let content: [Content]
}
