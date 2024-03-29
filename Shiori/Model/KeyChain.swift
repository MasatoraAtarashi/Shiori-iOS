//
//  KeyChain.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import KeychainAccess

protocol KeyChainDelegate {
    func didSaveToKeyChain()
    func didDeleteKeyChain()
    func didFailWithError(error: Error?)
}

struct KeyChain {
    var delegate: KeyChainDelegate?
    let keychain = Keychain(service: "com.masatoraatarashi.Shiori")
    func saveKeyChain(authResponse: AuthResponse) {
        do {
            try keychain.set(authResponse.uid, key: "uid")
            try keychain.set(authResponse.client, key: "client")
            try keychain.set(authResponse.accessToken, key: "accessToken")
            self.delegate?.didSaveToKeyChain()
        } catch {
            self.delegate?.didFailWithError(error: error)
        }
    }

    func getKeyChain() -> AuthResponse? {
        guard let uid = keychain["uid"] else {
            self.delegate?.didFailWithError(error: nil)
            return nil
        }
        guard let accessToken = keychain["accessToken"] else {
            self.delegate?.didFailWithError(error: nil)
            return nil
        }
        guard let client = keychain["client"] else {
            self.delegate?.didFailWithError(error: nil)
            return nil
        }
        let authResponse = AuthResponse(uid: uid, accessToken: accessToken, client: client)
        return authResponse
    }

    func deleteKeyChain() {
        do {
            try keychain.removeAll()
            self.delegate?.didDeleteKeyChain()
        } catch {
            self.delegate?.didFailWithError(error: error)
        }
    }
}
