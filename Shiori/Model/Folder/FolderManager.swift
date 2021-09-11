//
//  FolderManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/11.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol FolderManagerDelegate {
    func didCreateFolder(_ folderManager: FolderManager, folderResponse: FolderResponse)
    func didDeleteFolder(_ folderManager: FolderManager)
    func didFailWithError(error: Error)
}

struct FolderManager {
    var delegate: FolderManagerDelegate?

    // フォルダ作成
    func postFolder(folder: FolderRequest) {
        let postFolderURL = "\(const.baseURL)/v1/folder"
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(folder)
            performRequest(with: postFolderURL, httpMethod: "POST", body: body)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }
    
    // フォルダ削除
    func deleteFolder(folderId: Int) {
        let deleteFolderURL = "\(const.baseURL)/v1/folder/\(folderId)"
        performRequest(with: deleteFolderURL, httpMethod: "DELETE", body: nil)
    }

    func performRequest(with urlString: String, httpMethod: String, body: Foundation.Data?) {
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
                    self.delegate?.didDeleteFolder(self)
                }
                if let safeData = data {
                    if let folderResponse = self.parseJSON(safeData) {
                        self.delegate?.didCreateFolder(self, folderResponse: folderResponse)
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ folderData: Foundation.Data) -> FolderResponse? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(FolderResponse.self, from: folderData)
            return decodeData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
