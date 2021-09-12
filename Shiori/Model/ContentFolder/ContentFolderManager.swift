//
//  ContentFolderManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol ContentFolderManagerDelegate {
    func didUpdateContentFolder(_ contentFolderManager: ContentFolderManager)
    func didFailWithError(error: Error)
}

struct ContentFolderManager {
    var delegate: ContentFolderManagerDelegate?

    // フォルダにコンテンツを追加する
    func postContentToFolder(contentId: Int, folderId: Int) {
        let postContentToFolderURL = "\(const.baseURL)/v1/folder/\(folderId)/content/\(contentId)"
        performRequest(with: postContentToFolderURL, httpMethod: "POST")
    }

    // フォルダからコンテンツを取り除く
    func deleteContentToFolder(contentId: Int, folderId: Int) {
        let deleteContentToFolderURL = "\(const.baseURL)/v1/folder/\(folderId)/content/\(contentId)"
        performRequest(with: deleteContentToFolderURL, httpMethod: "DELETE")
    }

    func performRequest(with urlString: String, httpMethod: String) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
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
                self.delegate?.didUpdateContentFolder(self)
            }
            task.resume()
        }
    }
}
