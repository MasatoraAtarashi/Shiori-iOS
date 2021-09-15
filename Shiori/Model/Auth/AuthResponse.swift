//
//  AuthResponse.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct AuthResponse: Codable {
    let uid: String
    let accessToken: String
    let client: String

    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case accessToken = "Access-Token"
        case client = "client"
    }
}
