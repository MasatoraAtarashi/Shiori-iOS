//
//  ViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"
    
    var pageTitle: String = ""
    var link: String = ""
    var positionX: Int = 0
    var positionY: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getStoredDataFromUserDefault()
        
        self.tableView.refreshControl = refreshCtl
        self.tableView.refreshControl?.addTarget(self, action: #selector(ViewController.getStoredDataFromUserDefault), for: .valueChanged)
    }
    
    @objc func getStoredDataFromUserDefault() {
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
        let results = sharedDefaults.dictionary(forKey: self.keyName)
            // Safari を起動してそのURLに飛ぶ
//            print(url)
        self.link = results?["url"] as? String ?? ""
        self.pageTitle = results?["time"] as? String ?? "ばぁ"
        self.positionX = Int(results?["positionX"] as? String ?? "0") ?? 0
        self.positionY = Int(results?["positionY"] as? String ?? "0") ?? 0
        print(positionY)
//            UIApplication.shared.open(URL(string: url)!)
            // データの削除
            //sharedDefaults.removeObject(forKey: keyName)
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = self.pageTitle
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webViewController = WebViewController()
        webViewController.targetUrl = self.link
        webViewController.positionX = self.positionX
        webViewController.positionY = self.positionY
        parent!.navigationController!.pushViewController(webViewController , animated: true)
    }
}

