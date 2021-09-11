//
//  FolderListManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/11.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol FolderListManagerDelegate {
    func didUpdateFolderList(
        _ folderListManager: FolderListManager, folderListResponse: FolderListResponse)
    func didFailWithError(error: Error)
}

struct FolderListManager {
    var delegate: FolderListManagerDelegate?

    func fetchFolderList() {
        let getFolderListURL = "\(const.baseURL)/v1/folder"
        performRequest(with: getFolderListURL)
    }

    func performRequest(with urlString: String) {
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
                    if let folderListResponse = self.parseJSON(safeData) {
                        self.delegate?.didUpdateFolderList(
                            self, folderListResponse: folderListResponse)
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ folderListData: Foundation.Data) -> FolderListResponse? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(FolderListResponse.self, from: folderListData)
            return decodeData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
