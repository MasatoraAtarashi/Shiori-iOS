//
//  ContentRequest.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/04.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct ContentRequest: Codable {
    var title: String
    var url: String
    var userAgent: String?
    var device: String?
    var browser: String?
    var thumbnailImgUrl: String
    var scrollPositionX: Int
    var scrollPositionY: Int
    let maxScrollPositionX: Int
    let maxScrollPositionY: Int
    var videoPlaybackPosition: Int
    var audioPlaybackPosition: Int
    var specifiedText: String?
    var specifiedDomId: String?
    var specifiedDomClass: String?
    var specifiedDomTag: String?
    var windowInnerWidth: Int?
    var windowInnerHeight: Int?
    var windowOuterWidth: Int?
    var windowOuterHeight: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case url
        case userAgent = "user_agent"
        case device
        case browser
        case thumbnailImgUrl = "thumbnail_img_url"
        case scrollPositionX = "scroll_position_x"
        case scrollPositionY = "scroll_position_y"
        case maxScrollPositionX = "max_scroll_position_x"
        case maxScrollPositionY = "max_scroll_position_y"
        case videoPlaybackPosition = "video_playback_position"
        case audioPlaybackPosition = "audio_playback_position"
        case specifiedText = "specified_text"
        case specifiedDomId = "specified_dom_id"
        case specifiedDomClass = "specified_dom_class"
        case specifiedDomTag = "specified_dom_tag"
        case windowInnerWidth = "window_inner_width"
        case windowInnerHeight = "window_inner_height"
        case windowOuterWidth = "window_outer_width"
        case windowOuterHeight = "window_outer_height"
    }
}
