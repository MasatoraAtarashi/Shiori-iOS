//
//  LocalContentMigrationManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/20.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol LocalContentMigrationManagerDelegate {
    func didCreateContent(
        _ localContentMigrationManager: LocalContentMigrationManager,
        contentResponse: ContentResponse, localContentIndex: Int)
    func didFailWithError(error: Error)
}

// MARK: ローカルに保存されているコンテンツをアップロードする
// TODO: refactoring
struct LocalContentMigrationManager {
    var delegate: LocalContentMigrationManagerDelegate?

    func postContent(content: ContentRequest, localContentIndex: Int) {
        let postContentURL = "\(const.baseURL)/v1/content"
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(content)
            performRequest(
                with: postContentURL, httpMethod: "POST", body: body,
                localContentIndex: localContentIndex)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }

    func performRequest(
        with urlString: String, httpMethod: String, body: Foundation.Data?, localContentIndex: Int
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
                if let safeData = data {
                    if let contentResponse = self.parseJSON(safeData) {
                        self.delegate?.didCreateContent(
                            self, contentResponse: contentResponse,
                            localContentIndex: localContentIndex)
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
