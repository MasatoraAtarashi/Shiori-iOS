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
    var keyChain = KeyChain()

    override func viewDidLoad() {
        super.viewDidLoad()
        signInManager.delegate = self
        keyChain.delegate = self
    }

    @IBAction func signIn(_ sender: UIButton) {
        let email = self.emailInputField.text ?? ""
        let password = self.passwordInputField.text ?? ""
        let signInRequest = SignInRequest(email: email, password: password)
        signInManager.signIn(signInRequest: signInRequest)
    }
}

extension LoginViewController: SignInManagerDelegate, KeyChainDelegate {
    func didSaveToKeyChain() {
        // 認証画面・初期画面を閉じる
        self.presentingViewController?.presentingViewController?.dismiss(
            animated: true, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }

    func didDeleteKeyChain() {}

    func didSignIn(_ signInManager: SignInManager, authResponse: AuthResponse) {
        DispatchQueue.main.async {
            self.keyChain.saveKeyChain(authResponse: authResponse)

        }
    }

    func didFailWithError(error: Error?) {
        print("Error", error)
        const.showPopUp(is_success: false, title: "error", body: "メールアドレスまたはパスワードが正しくありません。")
    }
}
