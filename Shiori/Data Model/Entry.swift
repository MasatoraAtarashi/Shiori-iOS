//
//  Article.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/15.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import Foundation

struct Entry {
    // NOTE: positionX, positionY, videoPlaybackPositionはIntで保存すべきだった。いつか直したい
    var title: String
    var link: String
    var imageURL: String
    var positionX: String
    var positionY: String
    var date: String
    var folderInd: Array = [] as [String]
    var videoPlaybackPosition: String
}
