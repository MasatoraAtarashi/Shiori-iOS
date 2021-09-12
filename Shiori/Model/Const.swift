//
//  Const.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/08/31.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import SwiftMessages

// 定数クラス
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
    
    // ポップアップを表示する
    func showPopUp(is_success: Bool, title: String, body: String, iconText: String = "") {
            let popup = MessageView.viewFromNib(layout: .cardView)
            if is_success {
                popup.configureTheme(.success)
            } else {
                popup.configureTheme(.error)
            }
            popup.configureDropShadow()
            popup.configureContent(title: title, body: body, iconText: iconText)
            popup.button?.isHidden = true
            var popupConfig = SwiftMessages.defaultConfig
            popupConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
            SwiftMessages.show(config: popupConfig, view: popup)
        }
}
