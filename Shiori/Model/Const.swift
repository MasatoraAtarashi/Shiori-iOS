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
// TODO: shioriでしか使わないものはConstShioriに移す
struct Const {
    // APIのURL
    let baseURL: String = "https://web-shiori.herokuapp.com"
    // インジケータ
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 85, height: 85),
        type: NVActivityIndicatorType.ballSpinFadeLoader,
        color: UIColor.darkGray,
        padding: 0
    )
    // ホームとお気に入りフォルダを識別するためのid
    let HomeFolderId = -1
    let LikedFolderId = -2

    // ログインしているか判定するメソッド
    func isLoggedInUser() -> Bool {
        return KeyChain().getKeyChain() != nil
    }
}
