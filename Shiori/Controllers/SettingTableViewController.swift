//
//  SettingTableViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/03/27.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var switchAdvertisementDisplay: UISwitch!

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyRightLabel: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text4: UILabel!
    @IBOutlet weak var text5: UILabel!
    @IBOutlet weak var text6: UILabel!
    @IBOutlet weak var text7: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchAdvertisementDisplay.isOn = !UserDefaults.standard.bool(forKey: "isAdvertisementOn")
        switchAdvertisementDisplay.addTarget(self, action: #selector(self.onClickMySwicth(sender:)), for: UIControl.Event.valueChanged)
        
        //言語を変更
        changeLanguage()
        
        //バージョンを表示
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
          versionLabel.text = version
        }
        //コピーライトを表示
        copyRightLabel.text = "©Masatora Atarashi"
        
        (segmentControl.subviews[0] as UIView).backgroundColor = UIColor.white
        (segmentControl.subviews[1] as UIView).backgroundColor = UIColor(red: 255 / 255.0, green: 222 / 255.0, blue: 173 / 255.0, alpha: 0.5)
        (segmentControl.subviews[2] as UIView).backgroundColor = UIColor(red: 169 / 255.0, green: 169 / 255.0, blue: 169 / 255.0, alpha: 0.5)
        (segmentControl.subviews[3] as UIView).backgroundColor = UIColor.black
        segmentControl.addTarget(self, action: #selector(self.segmentChanged), for: UIControl.Event.valueChanged)
        segmentControl.layer.borderWidth = 0.5
        segmentControl.layer.borderColor = UIColor(red: 169 / 255.0, green: 169 / 255.0, blue: 169 / 255.0, alpha: 0.5).cgColor
    }
    
     @objc func segmentChanged(segcon: UISegmentedControl){
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
        let bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.navigationController?.toolbar.barTintColor = bgColor
        self.navigationController?.navigationBar.barTintColor = bgColor
        if r == 0 || r == 60 {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!]
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
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: // 「設定」のセクション
          return 2
        case 1: // 「その他」のセクション
          return 6
        default: // ここが実行されることはないはず
          return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1, 2] {
            guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1480539987?action=write-review")
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        } else if indexPath == [1, 1] {
            sendMail()
        }

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    //フィードバックのメールを送信
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients(["shiori.web.forsafari@gmail.com"]) // 宛先アドレス
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            mail.setSubject("Shiori web \(version ?? "") feedback") // 件名
            mail.setMessageBody("""
                
                
                ---
                version: \(version ?? "")
            """, isHTML: false) // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
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
    
    //言語を変更
    func changeLanguage() {
        text1.text = NSLocalizedString("Hide ads", comment: "")
        text2.text = NSLocalizedString("Usage", comment: "")
        text3.text = NSLocalizedString("Send feedback", comment: "")
        text4.text = NSLocalizedString("Rate Shiori web", comment: "")
        text5.text = NSLocalizedString("Version", comment: "")
        text6.text = NSLocalizedString("Copyright", comment: "")
        text7.text = NSLocalizedString("Supported video sites", comment: "")
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
