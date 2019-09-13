//
//  ViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"
    
    @IBOutlet weak var unkoLabel: UILabel!
    
    @IBAction func unko(_ sender: Any) {
        getStoredDataFromUserDefault()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getStoredDataFromUserDefault()
    }
    
    func getStoredDataFromUserDefault() {
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
        if let url = sharedDefaults.object(forKey: self.keyName) as? String {
            // Safari を起動してそのURLに飛ぶ
//            print(url)
            displayStoredData(url)
//            UIApplication.shared.open(URL(string: url)!)
            // データの削除
            //sharedDefaults.removeObject(forKey: keyName)
        } else {
            print("失敗")
        }
    }
    
    func displayStoredData(_ url: String = "") {
        print(url)
        if unkoLabel != nil {
         unkoLabel.text = url
        } else {
            print("nil")
        }
    }
}

