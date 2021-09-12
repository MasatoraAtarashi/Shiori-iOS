//
//  ContentManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/08/31.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol ContentListManagerDelegate {
    func didUpdateContentList(
        _ contentListManager: ContentListManager, contentListResponse: ContentListResponse)
    func didFailWithError(error: Error)
}

// 定数用
// TODO: どこかに移す
let const = Const()

struct ContentListManager {
    var delegate: ContentListManagerDelegate?

    // コンテンツ一覧を取得
    func fetchContentList(q: String = "", per_page: Int = 1000, page: Int = 1, liked: Bool = false)
    {
        let getContentListURL =
            "\(const.baseURL)/v1/content?q=\(q)&per_page=\(per_page)&page=\(page)&liked=\(liked)"
        performRequest(with: getContentListURL)
    }

    // フォルダ内コンテンツ一覧を取得
    // TODO: スクロール一番下まで行ったら追加で取得するようにする
    func fetchFolderContentList(folderId: Int, q: String = "", per_page: Int = 1000, page: Int = 1)
    {
        let getFolderContentListURL =
            "\(const.baseURL)/v1/folder/\(folderId)/content?q=\(q)&per_page=\(per_page)&page=\(page)"
        performRequest(with: getFolderContentListURL)
    }

    func performRequest(with urlString: String) {
        if let encodedURLString = urlString.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        {
            if let url = URL(string: encodedURLString) {
                var request = URLRequest(url: url)
                let authData = KeyChain().getKeyChain()

                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(authData?.uid, forHTTPHeaderField: "uid")
                request.setValue(authData?.client, forHTTPHeaderField: "client")
                request.setValue(authData?.accessToken, forHTTPHeaderField: "access-token")

                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let contentListResponse = self.parseJSON(safeData) {
                            self.delegate?.didUpdateContentList(
                                self, contentListResponse: contentListResponse)
                        }
                    }
                }
                task.resume()
            }
        }
    }

    func parseJSON(_ contentListData: Foundation.Data) -> ContentListResponse? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(ContentListResponse.self, from: contentListData)
            return decodeData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
