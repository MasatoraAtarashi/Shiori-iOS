//
//  ConstShiori.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/13.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import SwiftMessages

// Shiroiだけで使う共通処理・定数クラス
struct ConstShiori {
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
