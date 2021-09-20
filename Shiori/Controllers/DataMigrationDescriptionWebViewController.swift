//
//  DataMigrationDescriptionWebViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/20.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DataMigrationDescriptionWebViewController: UIViewController, WKNavigationDelegate,
    WKUIDelegate
{

    let wkWebView = WKWebView()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        initWebView(
            with: URL(string: "https://web-shiori.github.io/Shiori-iOS/Usage/data-migration")!)
    }

    func initWebView(with targetURL: URL) {
        wkWebView.frame = view.frame
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self

        let URLRequest = URLRequest(url: targetURL)
        wkWebView.load(URLRequest)
        view.addSubview(wkWebView)
    }
}
