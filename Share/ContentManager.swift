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
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body
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
                self.delegate?.didCreateContent(self)
            }
            task.resume()
        }
    }
}
