//
//  ContentManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/03.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol ContentManagerDelegate {
    func didUpdateContent(
        _ contentManager: ContentManager, contentResponse: ContentResponse)
    func didDeleteContent(_ contentManager: ContentManager)
    func didFailWithError(error: Error)
}

struct ContentManager {
    var delegate: ContentManagerDelegate?

    func deleteContent(contentId: Int) {
        let deleteContentURL = "\(const.baseURL)/v1/content/\(contentId)"
        performRequest(with: deleteContentURL, httpMethod: "DELETE", body: nil)
    }

    func putContent(contentId: Int, content: Content) {
        let putContentURL = "\(const.baseURL)/v1/content/\(contentId)"
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(content)
            performRequest(with: putContentURL, httpMethod: "PUT", body: body)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }

    func performRequest(
        with urlString: String, httpMethod: String, body: Foundation.Data?
    ) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
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
                if httpMethod == "DELETE" {
                    self.delegate?.didDeleteContent(self)
                    return
                }
                if let safeData = data {
                    if let contentResponse = self.parseJSON(safeData) {
                        self.delegate?.didUpdateContent(
                            self, contentResponse: contentResponse)
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ contentData: Foundation.Data) -> ContentResponse? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(ContentResponse.self, from: contentData)
            return decodeData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
