//
//  SignInRequest.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct AuthRequest: Codable {
    let email: String
    let password: String
    let passwordConfirmation: String?

    enum CodingKeys: String, CodingKey {
        case email
        case password
        case passwordConfirmation = "password_confirmation"
    }
}
