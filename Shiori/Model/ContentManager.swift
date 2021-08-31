//
//  ContentManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/08/31.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

let const = Const()
struct ContentManager {

    func fetchContentList() {
        let getContentListURL = "\(const.baseURL)/v1/content"
        performRequest(with: getContentListURL)
    }

    func performRequest(with urlString: String) {
        print("performRequest")
        print("performRequest")
        print("performRequest")
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
                    // エラー処理を書く
                    print("Error", error)
                    return
                }
                if let safeData = data {
                    if let contentList = self.parseJSON(safeData) {
                        for content in contentList.data.content {
                            print(content)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ contentListData: Foundation.Data) -> ContentListData? {
        print("parseJSON")
        print("parseJSON")
        print("parseJSON")
        print(String(data: contentListData, encoding: .utf8))

        print("parseJSON")
        print("parseJSON")
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(ContentListData.self, from: contentListData)
            return decodeData
        } catch {
            // エラー処理を書く
            print("Error: ", error)
            return nil
        }
    }
}
