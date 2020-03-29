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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchAdvertisementDisplay.isOn = !UserDefaults.standard.bool(forKey: "isAdvertisementOn")
        switchAdvertisementDisplay.addTarget(self, action: #selector(self.onClickMySwicth(sender:)), for: UIControl.Event.valueChanged)
        
        //バージョンを表示
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
          versionLabel.text = version
        }
        //コピーライトを表示
        copyRightLabel.text = "©Masatora Atarashi"
        
        (segmentControl.subviews[0] as UIView).backgroundColor = UIColor.white
        (segmentControl.subviews[1] as UIView).backgroundColor = UIColor(red: 250 / 255.0, green: 240 / 255.0, blue: 230 / 255.0, alpha: 0.5)
        (segmentControl.subviews[2] as UIView).backgroundColor = UIColor.lightGray
        (segmentControl.subviews[3] as UIView).backgroundColor = UIColor.black
        segmentControl.addTarget(self, action: #selector(self.segmentChanged), for: UIControl.Event.valueChanged)
        segmentControl.layer.borderWidth = 0.5
        segmentControl.layer.borderColor = UIColor(red: 169 / 255.0, green: 169 / 255.0, blue: 169 / 255.0, alpha: 0.5).cgColor
    }
    
     @objc func segmentChanged(segcon: UISegmentedControl){
        switch segcon.selectedSegmentIndex {
        case 0:
//            segmentControl.subviews[0].layer.borderColor = UIColor.green.cgColor
//            ViewController.view.backgroundColor = UIColor.black
//            ViewController().bgColor = UIColor.blue
//            navigationController?.navigationBar.barTintColor = UIColor.green
            print("Error")
            
        case 1:
//            segmentControl.subviews[1].layer.borderColor = UIColor.green.cgColor
            print("Error")
            
        case 2:
//            segmentControl.subviews[2].layer.borderColor = UIColor.green.cgColor
            print("Error")
            
        case 3:
//            segmentControl.subviews[3].layer.borderColor = UIColor.green.cgColor
            print("Error")
        default:
            print("Error")
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
//        self.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200);
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
          return 5
        default: // ここが実行されることはないはず
          return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1, 2] {
            SKStoreReviewController.requestReview()
        } else if indexPath == [1, 1] {
            sendMail()
        }

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients(["atarashi.masatora@gmail.com"]) // 宛先アドレス
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
