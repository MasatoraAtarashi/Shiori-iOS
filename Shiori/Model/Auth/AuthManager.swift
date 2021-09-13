//
//  SignInManager.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

protocol AuthManagerDelegate {
    func didSignIn(_ signInManager: AuthManager, authResponse: AuthResponse)
    func didAuthWithApple()
    func didFailWithError(error: Error?)
}

struct AuthManager {
    var delegate: AuthManagerDelegate?

    func authenticate(authRequest: AuthRequest, isSignIn: Bool, isAppleAuth: Bool) {
        var authURL = "\(const.baseURL)/v1/auth/"
        if isSignIn {
            authURL = "\(const.baseURL)/v1/auth/sign_in"
        }
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(authRequest)
            performRequest(with: authURL, body: body, isAppleAuth: isAppleAuth)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return
        }
    }

    func performRequest(with urlString: String, body: Foundation.Data, isAppleAuth: Bool) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    // TODO: オリジナルのエラーを作って渡す
                    guard let uid = httpResponse.allHeaderFields["Uid"] as? String else {
                        self.delegate?.didFailWithError(error: nil)
                        return
                    }
                    guard let accessToken = httpResponse.allHeaderFields["Access-Token"] as? String
                    else {
                        self.delegate?.didFailWithError(error: nil)
                        return
                    }
                    guard let client = httpResponse.allHeaderFields["Client"] as? String else {
                        self.delegate?.didFailWithError(error: nil)
                        return
                    }
                    let authResponse = AuthResponse(
                        uid: uid,
                        accessToken: accessToken,
                        client: client)
                    if isAppleAuth {
                        self.delegate?.didAuthWithApple()
                    } else {
                        self.delegate?.didSignIn(self, authResponse: authResponse)
                    }
                }
            }
            task.resume()
        }
    }
}
