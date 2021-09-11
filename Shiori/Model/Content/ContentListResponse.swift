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
    let per_page: String?  // Intに変換可能
    let page: String?  // Intに変換可能
    let nextPage: String?  // Intに変換可能
    let liked: String?  // Boolに変換可能
}

struct Data: Codable {
    let content: [Content]
}
