//
//  SignUpViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/14.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpWithTwitterButton: UIButton!
    @IBOutlet weak var signUpWithGithubButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        initViewUI()
    }

    func initViewUI() {
        // メールアドレス入力欄のUI
        emailInputField.layer.borderWidth = 1
        emailInputField.layer.borderColor = UIColor.opaqueSeparator.cgColor
        emailInputField.layer.cornerRadius = 5

        // パスワード入力欄のUI
        passwordInputField.layer.borderWidth = 1
        passwordInputField.layer.borderColor = UIColor.opaqueSeparator.cgColor
        passwordInputField.layer.cornerRadius = 5

        // 会員登録ボタンのUI
        signUpButton.layer.cornerRadius = 5

        // Twitter会員登録のUI
        signUpWithTwitterButton.layer.borderWidth = 1
        signUpWithTwitterButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        signUpWithTwitterButton.layer.cornerRadius = 5

        // Github会員登録のUI
        signUpWithGithubButton.layer.borderWidth = 1
        signUpWithGithubButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        signUpWithGithubButton.layer.cornerRadius = 5
    }
}
