//
//  LoginViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!

    var signInManager = SignInManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        signInManager.delegate = self
    }

    @IBAction func signIn(_ sender: UIButton) {
        let email = self.emailInputField.text ?? ""
        let password = self.passwordInputField.text ?? ""
        let signInRequest = SignInRequest(email: email, password: password)
        signInManager.signIn(signInRequest: signInRequest)
    }
}

extension LoginViewController: SignInManagerDelegate {
    func didSignIn(_ signInManager: SignInManager, authResponse: AuthResponse) {
        print("didSignIn")
        print(authResponse)
        // TODO: 画面を閉じる
    }

    func didFailWithError(error: Error?) {
        print("Error", error)
        // TODO: エラーをポップアップでユーザーに伝える
    }
}
