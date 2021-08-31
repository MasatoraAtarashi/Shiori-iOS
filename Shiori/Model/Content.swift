//
//  Content.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/01.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct Content: Codable {
    let id: Int
    let contentType: String
    let title: String
    let url: String
    let sharingUrl: String
    let fileUrl: String?
    let thumbnailImgUrl: String
    let scrollPositionX: Int
    let scrollPositionY: Int
    let maxScrollPositionX: Int
    let maxScrollPositionY: Int
    let videoPlaybackPosition: Int
    let specifiedText: String?
    let specifiedDomId: String?
    let specifiedDomClass: String?
    let specifiedDomTag: String?
    let liked: Bool?
    let deleteFlag: Bool
    let deletedAt: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case contentType
        case title
        case url
        case sharingUrl = "sharing_url"
        case fileUrl = "file_url"
        case thumbnailImgUrl = "thumbnail_img_url"
        case scrollPositionX = "scroll_position_x"
        case scrollPositionY = "scroll_position_y"
        case maxScrollPositionX = "max_scroll_position_x"
        case maxScrollPositionY = "max_scroll_position_y"
        case videoPlaybackPosition = "video_playback_position"
        case specifiedText = "specified_text"
        case specifiedDomId = "specified_dom_id"
        case specifiedDomClass = "specified_dom_class"
        case specifiedDomTag = "specified_dom_tag"
        case liked
        case deleteFlag = "delete_flag"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
