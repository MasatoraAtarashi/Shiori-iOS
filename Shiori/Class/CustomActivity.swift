//
//  CustomActivity.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/20.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit

public class CustomActivity: UIActivity {
    
    var title: String!
    var url: URL!
    
    public init(title: String, url: URL) {
        self.title = title
        self.url = url
        super.init()
        
    }

    // タイトル
    override public var activityTitle: String? {
        return "Safariで開く"
    }


    override public var activityImage: UIImage? {
        return UIImage(contentsOfFile: "ks_safari_activity_icon")
    }

    override public func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }

    // 動く直前にしたい動作
    override public func prepare(withActivityItems activityItems: [Any]) {
    }

    // 選択されたときにしたい処理
    override public func perform() {
        guard let url = self.url else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        self.activityDidFinish(true)
    }

}
