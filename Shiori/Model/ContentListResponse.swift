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

struct Content: Codable {
    let id: Int
    let content_type: String
    let title: String
    let url: String
    let sharing_url: String
    let file_url: String?
    let thumbnail_img_url: String
    let scroll_position_x: Int
    let scroll_position_y: Int
    let max_scroll_position_x: Int
    let max_scroll_position_y: Int
    let video_playback_position: Int
    let specified_text: String?
    let specified_dom_id: String?
    let specified_dom_class: String?
    let specified_dom_tag: String?
    let liked: Bool?
    let delete_flag: Bool
    let deleted_at: String?
    let created_at: String
    let updated_at: String
}
