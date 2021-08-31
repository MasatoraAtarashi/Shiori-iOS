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
let const = Const()

struct ContentListManager {
    var delegate: ContentListManagerDelegate?

    func fetchContentList() {
        print("fetchContentList")
        print("fetchContentList")
        print("fetchContentList")
        let getContentListURL = "\(const.baseURL)/v1/content"
        performRequest(with: getContentListURL)
    }

    func performRequest(with urlString: String) {
        print("performRequest")
        print("performRequest")
        print("performRequest")
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
                    print("safeData")
                    print("safeData")
                    print("safeData")
                    print("safeData")
                    print("safeData")
                    if let contentListResponse = self.parseJSON(safeData) {
                        print("成功")
                        print("成功")
                        print("成功")
                        print("成功")
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
