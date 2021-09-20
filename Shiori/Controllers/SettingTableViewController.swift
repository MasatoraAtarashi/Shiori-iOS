//
//  SettingTableViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/03/27.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import CoreData
import MessageUI
import NVActivityIndicatorView
import StoreKit
import UIKit

class SettingTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    var localContentMigrationManager = LocalContentMigrationManager()
    var keyChain = KeyChain()
    var isLoggedIn = false

    // MARK: IBOutlets
    @IBOutlet weak var contentUploadIndicatorView: NVActivityIndicatorView!

    // APPEARANCE セクション
    @IBOutlet weak var switchAdvertisementDisplay: UISwitch!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var text1: UILabel!

    // ACCOUNT セクション
    @IBOutlet weak var authButtonLabel: UILabel!

    // OTHER セクション
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text4: UILabel!
    @IBOutlet weak var text5: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var text6: UILabel!
    @IBOutlet weak var copyRightLabel: UILabel!

    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        localContentMigrationManager.delegate = self
        keyChain.delegate = self

        // TODO: refactoring
        isLoggedIn = Const().isLoggedInUser()

        initIndicator()
        showColorSettingPanel()
        showAdSetting()
        showVersion()
        showCopyright()
        changeLanguage()
    }

    override func viewWillAppear(_ animated: Bool) {
        changeSignInCell()
    }

    // MARK: IBActions
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:  // 「設定」のセクション
            return 2
        case 1:  // 「アカウント」のセクション
            return 3
        case 2:  // 「その他」のセクション
            return 5
        default:  // ここが実行されることはないはず
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1, 1] {  // データ移行
            showDataUploadConfirmAlert()
        } else if indexPath == [1, 2] {  // 認証
            if Const().isLoggedInUser() {
                showSignOutConfirmAlert()
            } else {
                showSignInView()
            }
        } else if indexPath == [2, 1] {  // フィードバックを送信
            sendMail()
        } else if indexPath == [2, 2] {  // Web Shioriを評価する
            guard
                let writeReviewURL = URL(
                    string: "https://itunes.apple.com/app/id1480539987?action=write-review")
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(
        _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: Other Methods
    func initIndicator() {
        self.contentUploadIndicatorView.color = .gray
    }

    // 背景色設定パネルを表示
    func showColorSettingPanel() {
        (segmentControl.subviews[0] as UIView).backgroundColor = UIColor.white
        (segmentControl.subviews[1] as UIView).backgroundColor = UIColor(
            red: 255 / 255.0, green: 222 / 255.0, blue: 173 / 255.0, alpha: 0.5)
        (segmentControl.subviews[2] as UIView).backgroundColor = UIColor(
            red: 169 / 255.0, green: 169 / 255.0, blue: 169 / 255.0, alpha: 0.5)
        (segmentControl.subviews[3] as UIView).backgroundColor = UIColor.black
        segmentControl.addTarget(
            self, action: #selector(self.segmentChanged), for: UIControl.Event.valueChanged)
        segmentControl.layer.borderWidth = 0.5
        segmentControl.layer.borderColor =
            UIColor(red: 169 / 255.0, green: 169 / 255.0, blue: 169 / 255.0, alpha: 0.5).cgColor
    }

    // 広告表示設定
    func showAdSetting() {
        switchAdvertisementDisplay.isOn = !UserDefaults.standard.bool(forKey: "isAdvertisementOn")
        switchAdvertisementDisplay.addTarget(
            self, action: #selector(self.onClickMySwicth(sender:)),
            for: UIControl.Event.valueChanged)
    }

    // バージョンを表示
    func showVersion() {
        if let version: String = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        {
            versionLabel.text = version
        }
    }

    // コピーライトを表示
    func showCopyright() {
        copyRightLabel.text = "©Masatora Atarashi"
    }

    // 言語を変更
    func changeLanguage() {
        text1.text = NSLocalizedString("Hide ads", comment: "")
        text2.text = NSLocalizedString("Usage", comment: "")
        text3.text = NSLocalizedString("Send feedback", comment: "")
        text4.text = NSLocalizedString("Rate Shiori web", comment: "")
        text5.text = NSLocalizedString("Version", comment: "")
        text6.text = NSLocalizedString("Copyright", comment: "")
    }

    // ログイン/ログアウトボタンの表示を変更
    func changeSignInCell() {
        if Const().isLoggedInUser() {
            self.authButtonLabel.text = "ログアウト"
            self.authButtonLabel.textColor = .red
        } else {
            self.authButtonLabel.text = "ログイン"
            self.authButtonLabel.textColor = Const().shioriPrimaryColor
        }
    }

    @objc func segmentChanged(segcon: UISegmentedControl) {
        switch segcon.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(255, forKey: "r")
            UserDefaults.standard.set(255, forKey: "g")
            UserDefaults.standard.set(255, forKey: "b")
        case 1:
            UserDefaults.standard.set(255, forKey: "r")
            UserDefaults.standard.set(222, forKey: "g")
            UserDefaults.standard.set(173, forKey: "b")
        case 2:
            UserDefaults.standard.set(60, forKey: "r")
            UserDefaults.standard.set(60, forKey: "g")
            UserDefaults.standard.set(60, forKey: "b")
        case 3:
            UserDefaults.standard.set(0, forKey: "r")
            UserDefaults.standard.set(0, forKey: "g")
            UserDefaults.standard.set(0, forKey: "b")
        default:
            print("Error")
        }
        let r = UserDefaults.standard.integer(forKey: "r")
        let b = UserDefaults.standard.integer(forKey: "b")
        let g = UserDefaults.standard.integer(forKey: "g")
        let bgColor: UIColor = UIColor(
            red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.navigationController?.toolbar.barTintColor = bgColor
        self.navigationController?.navigationBar.barTintColor = bgColor
        if r == 0 || r == 60 {
            self.navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!,
            ]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!,
            ]
        }
    }

    @objc func onClickMySwicth(sender: UISwitch) {
        if !sender.isOn {
            UserDefaults.standard.set(true, forKey: "isAdvertisementOn")
        } else {
            UserDefaults.standard.set(false, forKey: "isAdvertisementOn")
        }
        ViewController().changeDisplayAdvertisement()
    }

    // フィードバックのメールを送信
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
            mail.setToRecipients(["shiori.web.forsafari@gmail.com"])  // 宛先アドレス
            let version =
                Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            mail.setSubject("Shiori web \(version ?? "") feedback")  // 件名
            mail.setMessageBody(
                """


                    ---
                    version: \(version ?? "")
                """, isHTML: false)  // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    // MARK: アカウント関連コード
    // TODO: 実装
    // ログイン
    // ログアウトするか確認するアラート
    func showSignOutConfirmAlert() {
        let alert: UIAlertController = UIAlertController(
            title: "", message: "ログアウトしますか？", preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "ログアウト", style: UIAlertAction.Style.destructive,
            handler: {
                (action: UIAlertAction!) -> Void in
                self.signOut()
            })
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "キャンセル", style: UIAlertAction.Style.cancel,
            handler: {
                (action: UIAlertAction!) -> Void in
            })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    // ログアウト
    func signOut() {
        keyChain.deleteKeyChain()
    }

    func showSignInView() {
        // チュートリアル画面を表示
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC =
            storyboard.instantiateViewController(withIdentifier: "InitialViewController")
            as! InitialViewController
        initialVC.modalPresentationStyle = .fullScreen
        self.present(initialVC, animated: true, completion: nil)
    }

    // MARK: データ移行(アップロード)関連コード
    // データ移行を実行するか確認するアラート
    func showDataUploadConfirmAlert() {
        let alert: UIAlertController = UIAlertController(
            title: "データを移行しますか？", message: "データ移行を実行するとサーバにブックマークデータがアップロードされます。",
            preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "データ移行", style: UIAlertAction.Style.destructive,
            handler: {
                (action: UIAlertAction!) -> Void in
                self.uploadAllLocalContent()
            })
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "キャンセル", style: UIAlertAction.Style.cancel,
            handler: {
                (action: UIAlertAction!) -> Void in
            })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    var articles: [Article] = []
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"

    // ローカルに存在するコンテンツをすべてアップロードする
    func uploadAllLocalContent() {
        getStoredDataFromUserDefault()

        // 作業中であることを表示する(インジケータ&メッセージ)
        self.contentUploadIndicatorView.frame.size.height = 100
        self.contentUploadIndicatorView.startAnimating()
        // コンテンツをすべてアップロード
        for (i, article) in articles.enumerated().reversed() {
            let contentRequest = ContentRequest(
                title: article.title ?? "",
                url: article.link ?? "",
                thumbnailImgUrl: article.imageURL ?? "",
                scrollPositionX: 0,
                scrollPositionY: Int(article.positionY ?? "0") ?? 0,
                maxScrollPositionX: 0,
                maxScrollPositionY: Int(article.maxScrollPositionY ?? "0") ?? 0,
                videoPlaybackPosition: Int(article.videoPlaybackPosition ?? "0") ?? 0,
                specifiedText: nil,
                specifiedDomId: nil,
                specifiedDomClass: nil,
                specifiedDomTag: nil
            )
            localContentMigrationManager.postContent(content: contentRequest, localContentIndex: i)
        }
    }

    // ローカルストレージ内の記事を取得する
    @objc func getStoredDataFromUserDefault() {
        self.articles = []
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
        let storedArray: [[String: String]] =
            sharedDefaults.array(forKey: self.keyName) as? [[String: String]] ?? []

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            .viewContext

        for result in storedArray {
            let article = Article(context: context)
            article.title = result["title"]!
            article.link = result["url"]!
            article.imageURL = result["image"]!
            article.positionX = result["positionX"]!
            article.positionY = result["positionY"]!
            article.maxScrollPositionX = result["maxScrollPositionX"] ?? "0"
            article.maxScrollPositionY = result["maxScrollPositionY"] ?? "0"
            article.date = result["date"]!
            article.videoPlaybackPosition = result["videoPlaybackPosition"]
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }

        sharedDefaults.set([], forKey: self.keyName)

        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            .viewContext
        do {
            let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
            self.articles = try readContext.fetch(fetchRequest)
        } catch {
            print("Error")
        }

        articles.reverse()
    }

    // MARK: Subscripts
}

// MARK: Extensions
extension SettingTableViewController: LocalContentMigrationManagerDelegate {
    func didCreateContent(
        _ localContentMigrationManager: LocalContentMigrationManager,
        contentResponse: ContentResponse, localContentIndex: Int
    ) {
        DispatchQueue.main.async {
            if self.articles.count == 1 {
                self.contentUploadIndicatorView.stopAnimating()
                ConstShiori().showPopUp(
                    is_success: true, title: "Success", body: "データ移行完了しました。")
            } else {
                if let index = self.articles.firstIndex(where: {
                    $0.title == contentResponse.data.title
                }) {
                    self.articles.remove(at: index)
                }
            }
        }
    }

    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            ConstShiori().showPopUp(
                is_success: false, title: "error", body: "データ移行に失敗しました。")
            self.contentUploadIndicatorView.stopAnimating()
            print("Error", error)
        }
    }

}

extension SettingTableViewController: KeyChainDelegate {
    func didSaveToKeyChain() {
    }

    func didDeleteKeyChain() {
        // チュートリアル画面を表示
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC =
            storyboard.instantiateViewController(withIdentifier: "InitialViewController")
            as! InitialViewController
        initialVC.modalPresentationStyle = .fullScreen
        self.present(initialVC, animated: true, completion: nil)
    }

    func didFailWithError(error: Error?) {
        print("Error", error)
    }

}
