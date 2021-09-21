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
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        initWebView(
            with: URL(string: "https://web-shiori.github.io/Shiori-iOS/Usage/data-migration")!)

        // TODO: リファクタリング
        refreshControl = UIRefreshControl()
        wkWebView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(
            self, action: #selector(WebViewController.refresh(sender:)), for: .valueChanged)
    }

    func initWebView(with targetURL: URL) {
        wkWebView.frame = view.frame
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self

        let URLRequest = URLRequest(url: targetURL)
        wkWebView.load(URLRequest)
        view.addSubview(wkWebView)

    }

    @objc func refresh(sender: UIRefreshControl) {
        guard let url = wkWebView.url else {
            return
        }
        wkWebView.load(URLRequest(url: url))
    }
}
