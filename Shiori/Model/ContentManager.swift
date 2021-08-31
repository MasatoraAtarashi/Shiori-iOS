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
        let getContentListURL = "\(const.baseURL)/heartbeat"
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
            print("url ok")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    // エラー処理を書く
                    print("Error", error)
                    return
                }
                if let safeData = data {
                    //                    if let contentList = self.parseJSON(safeData) {
                    //                        print(contentList)
                    //                    }
                    print(response)
                }
                print(data)
                print(response)
            }
            task.resume()
        }
    }

    //    func parseJSON(_ contentListData: Data) -> [ContentModel?] {
    //        let decoder = JSONDecoder()
    //        do {
    //            let decodeData try de
    //        } catch {
    //            // エラー処理を書く
    //            print("Error")
    //            return nil
    //        }
    //    }
}
