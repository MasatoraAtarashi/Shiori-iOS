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

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    var refreshControll: UIRefreshControl!
    var shareButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwadButton: UIBarButtonItem!
    
    var targetUrl: String?
    var positionX: Int = 0
    var positionY: Int = 0
    
    let preferences = WKPreferences()
    let segment: UISegmentedControl = UISegmentedControl(items: ["web", "smart"])
    
    override func loadView() {
        
        let webConfiguration = WKWebViewConfiguration()
        
        
//        segment.sizeToFit()
//        segment.tintColor = UIColor.white
//        segment.selectedSegmentIndex = 0;
//        segment.addTarget(self, action: "segmentChanged", for: .valueChanged)
//        self.navigationItem.titleView = segment
        
        webConfiguration.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myRequest: URLRequest?
        if let targetURL = targetUrl {
            myRequest = URLRequest(url: URL(string:targetURL)!)
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
        self.toolbarItems = [flexibleItem,backButton,fixedItem,forwadButton,flexibleItem]
        
        refreshControll = UIRefreshControl()
        self.webView.scrollView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(WebViewController.refresh(sender:)), for: .valueChanged)
        
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        print("refresh")
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
        
        // 使用しないアクティビティタイプ
        //        let excludedActivityTypes = [
        //            UIActivity.ActivityType.postToFacebook,
        //            UIActivity.ActivityType.postToTwitter,
        //            UIActivity.ActivityType.message,
        //            UIActivity.ActivityType.saveToCameraRoll,
        //            UIActivity.ActivityType.print
        //        ]
        ////
        //        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func segmentChanged() {
        print("unko")
        //セグメントが変更されたときの処理
        //選択されているセグメントのインデックス
        if self.segment.selectedSegmentIndex == 0 {
            self.preferences.javaScriptEnabled = true
            webView.reload()
            print("0")
        } else {
            self.preferences.javaScriptEnabled = false
            webView.reload()
            print("1")
        }
    }
    
   
}

//MARK: 読み込み
extension WebViewController {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.scrollTo(\(positionX),\(positionY))", completionHandler: nil)
        print("遷移開始")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !(targetUrl?.contains("https") ?? true) {
            webView.evaluateJavaScript("window.scrollTo(\(positionX),\(positionY))", completionHandler: nil)
        }
        positionX = 0
        positionY = 0
        print("loaded")
        self.refreshControll.endRefreshing()
        //        backButton.isHidden = (webView.canGoBack) ? false : true
        //        forwadButton.isHidden = (webView.canGoForward) ? false : true
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


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


