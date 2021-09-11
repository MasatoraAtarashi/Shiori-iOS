//
//  Const.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/08/31.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

// 定数クラス
struct Const {
    let baseURL: String = "https://web-shiori.herokuapp.com"
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 85, height: 85),
        type: NVActivityIndicatorType.ballSpinFadeLoader,
        color: UIColor.darkGray,
        padding: 0
    )
}
