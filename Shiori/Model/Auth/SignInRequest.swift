//
//  SignInRequest.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation

struct SignInRequest: Codable {
    let email: String
    let password: String
}
