//
//  LoginViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import AuthenticationServices
import FontAwesome_swift
import Foundation
import UIKit

// NOTE: 会員登録画面・ログイン画面共有
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInWithTwitterButton: UIButton!
    @IBOutlet weak var signInWithGithubButton: UIButton!
    @IBOutlet weak var signInWithAppleButton: UIButton!

    var authManager = AuthManager()
    var keyChain = KeyChain()

    override func viewDidLoad() {
        super.viewDidLoad()
        authManager.delegate = self
        keyChain.delegate = self
        emailInputField.delegate = self
        passwordInputField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        initViewUI()

        //        NSNotificationCenter.defaultCenter().addObserver(self,
        //                    selector: "keyboardWillBeShown:",
        //                    name: UIKeyboardWillShowNotification,
        //                    object: nil)
        //                NSNotificationCenter.defaultCenter().addObserver(self,
        //                    selector: "keyboardWillBeHidden:",
        //                    name: UIKeyboardWillHideNotification,
        //                    object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var targetService = ""
        if segue.identifier == "signInWithGoogle" {
            targetService = "Google"
        } else if segue.identifier == "signInWithTwitter" {
            targetService = "Twitter"
        } else if segue.identifier == "signInWithGithub" {
            targetService = "Github"
        }

        let nextVC = segue.destination as? UINavigationController
        let omniAuthWebVC = nextVC?.children.first as? OmniAuthWebViewController
        omniAuthWebVC?.targetService = targetService
    }

    @IBAction func signIn(_ sender: UIButton) {
        let email = self.emailInputField.text ?? ""
        let password = self.passwordInputField.text ?? ""
        let authRequest = AuthRequest(email: email, password: password, passwordConfirmation: nil)
        authManager.authenticate(authRequest: authRequest, isSignIn: true, isAppleAuth: false)
    }

    @IBAction func signUp(_ sender: UIButton) {
        let email = self.emailInputField.text ?? ""
        let password = self.passwordInputField.text ?? ""
        let authRequest = AuthRequest(
            email: email, password: password, passwordConfirmation: password)
        authManager.authenticate(authRequest: authRequest, isSignIn: false, isAppleAuth: false)
    }

    // NOTE: Googleにアプリを承認されるまで使わない
    @IBAction func signInWithGoogle(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signInWithGoogle", sender: nil)
    }

    @IBAction func signInWithTwitter(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signInWithTwitter", sender: nil)
    }

    @IBAction func signInWithGithub(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signInWithGithub", sender: nil)
    }

    @IBAction func signInWithApple(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func keyboardWillBeShown(notification: NSNotification) {
    }

    func keyboardWillBeHidden(notification: NSNotification) {
    }

    //改行ボタンが押された際に呼ばれる.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // UIを初期化
    func initViewUI() {
        // メールアドレス入力欄のUI
        emailInputField.layer.borderWidth = 1
        emailInputField.layer.borderColor = UIColor.opaqueSeparator.cgColor
        emailInputField.layer.cornerRadius = 5

        // パスワード入力欄のUI
        passwordInputField.layer.borderWidth = 1
        passwordInputField.layer.borderColor = UIColor.opaqueSeparator.cgColor
        passwordInputField.layer.cornerRadius = 5

        // ログインボタンのUI
        signInButton.layer.cornerRadius = 5

        // TwitterログインのUI
        signInWithTwitterButton.layer.borderWidth = 1
        signInWithTwitterButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        signInWithTwitterButton.layer.cornerRadius = 5

        // GithubログインのUI
        signInWithGithubButton.layer.borderWidth = 1
        signInWithGithubButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        signInWithGithubButton.layer.cornerRadius = 5
    }
}

extension LoginViewController: AuthManagerDelegate, KeyChainDelegate {
    func didAuthWithApple(authResponse: AuthResponse) {
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: "already_sign_in_with_apple?")
            self.keyChain.saveKeyChain(authResponse: authResponse)
        }
    }

    func didSaveToKeyChain() {
        DispatchQueue.main.async {
            self.closeAuthView()
        }
    }

    // 認証画面・初期画面を閉じる
    func closeAuthView() {
        DispatchQueue.main.async {
            self.presentingViewController?.presentingViewController?.dismiss(
                animated: true, completion: nil)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func didDeleteKeyChain() {}

    func didSignIn(_ signInManager: AuthManager, authResponse: AuthResponse) {
        DispatchQueue.main.async {
            self.keyChain.saveKeyChain(authResponse: authResponse)
        }
    }

    func didFailWithError(error: Error?) {
        DispatchQueue.main.async {
            print("Error", error)
            ConstShiori().showPopUp(
                is_success: false, title: "error", body: "メールアドレスまたはパスワードが正しくありません。")
        }
    }
}

// authentication with apple
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let email = userIdentifier + "@apple.com"

            if UserDefaults.standard.bool(forKey: "already_sign_in_with_apple?") {
                let authRequest = AuthRequest(
                    email: email, password: userIdentifier, passwordConfirmation: nil)
                authManager.authenticate(
                    authRequest: authRequest, isSignIn: true, isAppleAuth: true)
            } else {
                // TODO: 会員登録
                let authRequest = AuthRequest(
                    email: email, password: userIdentifier, passwordConfirmation: userIdentifier)
                authManager.authenticate(
                    authRequest: authRequest, isSignIn: false, isAppleAuth: true)
            }
        }
    }
}
