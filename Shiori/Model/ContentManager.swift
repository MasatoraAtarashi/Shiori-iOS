//
//  ContentManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/03.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol ContentManagerDelegate {
    func didCreateContent(_ contentManager: ContentManager, contentResponse: ContentResponse)
    func didUpdateContent(
        _ contentManager: ContentManager, contentResponse: ContentResponse, at indexPath: IndexPath)
    func didDeleteContent(_ contentManager: ContentManager)
    func didFailWithError(error: Error)
}

struct ContentManager {
    var delegate: ContentManagerDelegate?

    func postContent() {
        // TODO: implement
    }

    func deleteContent() {
        // TODO: implement
    }

    func putContent(at indexPath: IndexPath, contentId: Int, content: Content) {
        let putContentURL = "\(const.baseURL)/v1/content/\(contentId)"
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(content)
            performRequest(with: putContentURL, httpMethod: "PUT", body: body, at: indexPath)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }

    func performRequest(
        with urlString: String, httpMethod: String, body: Foundation.Data?, at indexPath: IndexPath?
    ) {
        print("performRequest")
        print("performRequest")
        print("performRequest")
        print("performRequest")
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
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
                if httpMethod == "DELETE" {
                    self.delegate?.didDeleteContent(self)
                    return
                }
                if let safeData = data {
                    if let contentResponse = self.parseJSON(safeData) {
                        print("contentResponse")
                        print("contentResponse")
                        print("contentResponse")
                        if httpMethod == "POST" {
                            self.delegate?.didCreateContent(self, contentResponse: contentResponse)
                        } else if httpMethod == "PUT" {
                            self.delegate?.didUpdateContent(
                                self, contentResponse: contentResponse, at: indexPath!)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ contentData: Foundation.Data) -> ContentResponse? {
        print("parseJSON")
        print("parseJSON")
        print("parseJSON")
        print(String(bytes: contentData, encoding: .utf8))
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(ContentResponse.self, from: contentData)
            return decodeData
        } catch {
            print("Error", error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
