//
//  WebViewController.swift
//  FishNews
//
//  Created by あたらしまさとら on 2019/08/30.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import Accounts
import NVActivityIndicatorView
import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    var webView: WKWebView!
    var refreshControll: UIRefreshControl!
    var shareButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwadButton: UIBarButtonItem!
    var targetUrl: String?
    // TODO: 変数名変える
    var positionX: Int = 0
    var positionY: Int = 0
    var maxScroolPositionX: Int = 0
    var maxScroolPositionY: Int = 0
    var videoPlaybackPosition: Int = 0
    var audioPlaybackPosition: Int = 0

    let preferences = WKPreferences()
    let segment: UISegmentedControl = UISegmentedControl(items: ["web", "smart"])

    // MARK: IBOutlets
    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods

    // TODO: リファクタリング
    override func loadView() {

        let webConfiguration = WKWebViewConfiguration()

        // インライン再生を許可
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView

        webView.addSubview(const.activityIndicatorView)
        webView.bringSubviewToFront(const.activityIndicatorView)

        webView.allowsBackForwardNavigationGestures = true
    }

    // TODO: リファクタリング
    override func viewDidLoad() {
        super.viewDidLoad()

        let myRequest: URLRequest?
        if let targetURL = targetUrl {
            myRequest = URLRequest(url: URL(string: targetURL)!)
            webView.load(myRequest!)
        } else {
            webView.stopLoading()
        }

        shareButton = UIBarButtonItem(
            barButtonSystemItem: .action, target: self, action: #selector(sharePage))
        shareButton.tintColor = UIColor.init(
            red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 1)
        self.navigationItem.rightBarButtonItem = shareButton

        self.navigationController?.setToolbarHidden(false, animated: true)
        backButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 101)!, target: self,
            action: #selector(goBack))
        backButton.tintColor = UIColor.init(
            red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 1)
        let flexibleItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let fixedItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedItem.width = 100
        forwadButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 102)!, target: self,
            action: #selector(goForward))
        forwadButton.tintColor = UIColor.init(
            red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 1)
        self.toolbarItems = [flexibleItem, backButton, fixedItem, forwadButton, flexibleItem]

        refreshControll = UIRefreshControl()
        self.webView.scrollView.refreshControl = refreshControll
        refreshControll.addTarget(
            self, action: #selector(WebViewController.refresh(sender:)), for: .valueChanged)
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

    // MARK: IBActions
    // MARK: Other Methods
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
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: [
                CustomActivity(title: shareText ?? "", url: shareWebsite as URL)
            ])

        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }

    // MARK: Subscripts
}

// MARK: Extensions
// 読み込み
extension WebViewController {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        const.activityIndicatorView.center = webView.center
        const.activityIndicatorView.startAnimating()
    }
    

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // TODO: メソッドに切り出す
        self.webView.evaluateJavaScript(
            "window.scrollTo(\(0),\(positionY))",
            completionHandler: { _, _ in
                // ユーザーがリロードしたときスクロールしないようにpositionを初期化
                self.positionX = 0
                self.positionY = 0
            }
        )
        
        if let url = targetUrl {
            if url.hasPrefix("https://youtu.be/") || url.contains("pornhub")
                || url.contains("nicovideo") || url.contains("dailymotion") || url.contains("tube8")
                || url.contains("redtube")
            {
                return
            }
            setVideoPlayBackPosition(videoPlayBackPosition: videoPlaybackPosition)
        }
        setAudioPlayBackPosition(audioPlayBackPosition: audioPlaybackPosition)

        self.refreshControll.endRefreshing()
        const.activityIndicatorView.stopAnimating()
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
        //        // リンククリックは全部Safariに飛ばしたい
        //        if navigationAction.navigationType == WKNavigationType.linkActivated {
        //            UIApplication.shared.open(navigationAction.request.url!)
        //            decisionHandler(.cancel)
        //        } else {
        //            decisionHandler(.allow)
        //        }
    }

    // スクロール位置を復元する

    // 動画再生位置を復元する
    func setVideoPlayBackPosition(videoPlayBackPosition: Int) {
        let setVideoPlaybackPositionScript = """
                var video = document.getElementsByTagName('video')[0];
                if (video) {
                    video.currentTime = \(videoPlayBackPosition);
                }
            """
        webView.evaluateJavaScript(setVideoPlaybackPositionScript, completionHandler: nil)
    }
    
    // 音声再生位置を復元する
    func setAudioPlayBackPosition(audioPlayBackPosition: Int) {
        let setAudioPlaybackPositionScript = """
                var audio = document.getElementsByTagName('audio')[0];
                if (audio) {
                    audio.currentTime = \(audioPlaybackPosition);
                };
            """
        webView.evaluateJavaScript(setAudioPlaybackPositionScript, completionHandler: nil)
    }
}

// target=_blank対策
extension WebViewController {

    func webView(
        _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
    ) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

}
