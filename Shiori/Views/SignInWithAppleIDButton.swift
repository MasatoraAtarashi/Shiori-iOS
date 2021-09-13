//
//  SignInWithAppleIDButton.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/14.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import AuthenticationServices
import UIKit

@IBDesignable
class SignInWithAppleIDButton: UIButton {

    private var appleIDButton: ASAuthorizationAppleIDButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        appleIDButton = ASAuthorizationAppleIDButton(
            authorizationButtonType: .default, authorizationButtonStyle: .black)

        addSubview(appleIDButton)

        appleIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleIDButton.topAnchor.constraint(equalTo: self.topAnchor),
            appleIDButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            appleIDButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            appleIDButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
