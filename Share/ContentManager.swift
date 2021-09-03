//
//  ContentManager.swift
//  Share
//
//  Created by あたらしまさとら on 2021/09/04.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol ContentManagerDelegate {
    func didCreateContent(_ contentManager: ContentManager)
    func didFailWithError(error: Error)
}

struct ContentManager {
    var delegate: ContentManagerDelegate?

    func postContent(content: ContentRequest) {
        let postContentURL = "\(Const().baseURL)/v1/content"
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(content)
            performRequest(with: postContentURL, body: body)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }

    func performRequest(
        with urlString: String, body: Foundation.Data?
    ) {
        print("performRequest")
        print("performRequest")
        print("performRequest")
        print("performRequest")
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body
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
                print(response)
                self.delegate?.didCreateContent(self)
            }
            task.resume()
        }
    }
}
