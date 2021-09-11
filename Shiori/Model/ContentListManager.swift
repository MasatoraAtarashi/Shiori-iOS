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

    func fetchContentList(q: String = "", per_page: Int = 50, page: Int = 1, liked: Bool = false) {
        let getContentListURL =
            "\(const.baseURL)/v1/content?q=\(q)&per_page=\(per_page)&page=\(page)&liked=\(liked)"
        performRequest(with: getContentListURL)
    }

    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // TODO: ちゃんとした値を入れる
            request.setValue("unko@gmail.com", forHTTPHeaderField: "uid")
            request.setValue("BTDPytpbkqjPSzlHWmj0fg", forHTTPHeaderField: "client")
            request.setValue("8sT9I1VQ5qAx_MkqUBLb2Q", forHTTPHeaderField: "access-token")
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
