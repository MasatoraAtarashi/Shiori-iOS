//
//  WebViewController.swift
//  FishNews
//
//  Created by あたらしまさとら on 2019/08/30.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit
import WebKit
import Accounts
import NVActivityIndicatorView

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var refreshControll: UIRefreshControl!
    var shareButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwadButton: UIBarButtonItem!

    var activityIndicatorView: NVActivityIndicatorView?

    var targetUrl: String?
    var positionX: Int = 0
    var positionY: Int = 0

    let preferences = WKPreferences()
    let segment: UISegmentedControl = UISegmentedControl(items: ["web", "smart"])

    override func loadView() {

        let webConfiguration = WKWebViewConfiguration()

        activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 85, height: 85),
            type: NVActivityIndicatorType.ballSpinFadeLoader,
            color: UIColor.darkGray,
            padding: 0
        )

        webConfiguration.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView

        if let activityView = activityIndicatorView {
            webView.addSubview(activityView)
            webView.bringSubviewToFront(activityView)
        }

        webView.allowsBackForwardNavigationGestures = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let myRequest: URLRequest?
        if let targetURL = targetUrl {
            myRequest = URLRequest(url: URL(string: targetURL)!)
            webView.load(myRequest!)
        } else {
            webView.stopLoading()
        }

        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePage))
        shareButton.tintColor = UIColor.init(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = shareButton

        self.navigationController?.setToolbarHidden(false, animated: true)
        backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 101)!, target: self, action: #selector(goBack))
        backButton.tintColor = UIColor.init(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let fixedItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedItem.width = 100
        forwadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 102)!, target: self, action: #selector(goForward))
        forwadButton.tintColor = UIColor.init(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
        self.toolbarItems = [flexibleItem, backButton, fixedItem, forwadButton, flexibleItem]

        refreshControll = UIRefreshControl()
        self.webView.scrollView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(WebViewController.refresh(sender:)), for: .valueChanged)
    }

    @objc func refresh(sender: UIRefreshControl) {
        guard let url = webView.url else {
            return
        }
        webView.load(URLRequest(url: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func goBack() {
        webView.goBack()
    }

    @objc private func goForward() {
        webView.goForward()
    }

    @objc func sharePage() {
        // 共有する項目
        let shareText = webView.title
        let shareWebsite: NSURL
        if let shareURL = webView?.url {
            shareWebsite = shareURL as NSURL
        } else {
            return
        }

        let activityItems = [shareText, shareWebsite] as [Any]

        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [CustomActivity(title: shareText ?? "", url: shareWebsite as URL)])

        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }

    @objc func segmentChanged() {
        // セグメントが変更されたときの処理
        // 選択されているセグメントのインデックス
        if self.segment.selectedSegmentIndex == 0 {
            self.preferences.javaScriptEnabled = true
            webView.reload()
        } else {
            self.preferences.javaScriptEnabled = false
            webView.reload()
        }
    }

}

// MARK: 読み込み
extension WebViewController {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicatorView?.center = webView.center
        activityIndicatorView?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.scrollTo(\(positionX),\(positionY))", completionHandler: nil)
        // ユーザーがリロードしたときスクロールしないようにpositionを初期化
        positionX = 0
        positionY = 0
        self.refreshControll.endRefreshing()
        activityIndicatorView?.stopAnimating()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // リンククリックは全部Safariに飛ばしたい
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// target=_blank対策
extension WebViewController {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

}
