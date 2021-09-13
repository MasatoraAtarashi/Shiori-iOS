//
//  OmniAuthWebViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/13.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class OmniAuthWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var keyChain = KeyChain()

    var targetService = "unko"
    let wkWebView = WKWebView()
    let refreshControl = UIRefreshControl()
    var callbackURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        keyChain.delegate = self

        if let targetURL = setTargetURL(targetService: targetService) {
            initWebView(with: targetURL)
        }
    }

    func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        decisionHandler(.allow)

        // TODO: リファクタリング
        guard let httpURLResponse = navigationResponse.response as? HTTPURLResponse else {
            return
        }
        let headers = httpURLResponse.allHeaderFields
        guard let uid = headers["Uid "] as? String else {
            return
        }
        guard let accessToken = headers["Access-Token"] as? String
        else {
            return
        }
        guard let client = headers["Client"] as? String else {
            return
        }
        let authResponse = AuthResponse(
            uid: uid,
            accessToken: accessToken,
            client: client)
        print(authResponse)
        keyChain.saveKeyChain(authResponse: authResponse)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
    }

    func setTargetURL(targetService: String) -> URL? {
        switch targetService {
        case "Google":
            return URL(string: "\(const.baseURL)/v1/auth/google_oauth2")
        case "Twitter":
            return URL(string: "\(const.baseURL)/v1/auth/twitter")
        case "Github":
            return URL(string: "\(const.baseURL)/v1/auth/github")
        default:
            // TODO: エラー処理
            return nil
        }
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

extension OmniAuthWebViewController: KeyChainDelegate {
    func didSaveToKeyChain() {
        // 認証画面・初期画面を閉じる
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(
            animated: true, completion: nil)
        self.presentingViewController?.presentingViewController?.dismiss(
            animated: true, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }

    func didDeleteKeyChain() {}

    func didFailWithError(error: Error?) {
        DispatchQueue.main.async {
            print("Error", error)
            ConstShiori().showPopUp(
                is_success: false, title: "error", body: "メールアドレスまたはパスワードが正しくありません。")
        }
    }

}
