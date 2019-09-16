//
//  ViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"
    
    var pageTitle: String = ""
    var link: String = ""
    var positionX: Int = 0
    var positionY: Int = 0
    
    var articles: [Entry] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        
        // Do any additional setup after loading the view.
        getStoredDataFromUserDefault()
        
        self.tableView.refreshControl = refreshCtl
        self.tableView.refreshControl?.addTarget(self, action: #selector(ViewController.getStoredDataFromUserDefault), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func getStoredDataFromUserDefault() {
        self.articles = []
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//        let results = sharedDefaults.dictionary(forKey: self.keyName)
            // Safari を起動してそのURLに飛ぶ
//            print(url)
//        self.link = results?["url"] as? String ?? ""
//        self.pageTitle = results?["title"] as? String ?? ""
//        print(self.pageTitle)
//        self.positionX = Int(results?["positionX"] as? String ?? "0") ?? 0
//        self.positionY = Int(results?["positionY"] as? String ?? "0") ?? 0
        var storedArray: [Dictionary<String, String>] = sharedDefaults.array(forKey: self.keyName) as? [Dictionary<String, String>] ?? []
        for result in storedArray {
            self.articles.append(Entry(
                title: result["title"]!,
                link: result["url"]!,
                imageURL: result["image"]!,
                positionX: result["positionX"]!,
                positionY: result["positionY"]!
            ))
        }
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(articles.count)
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath as IndexPath) as! FeedTableViewCell
        let entry = self.articles[indexPath.row]
        cell.title.text = entry.title
        cell.thumbnail.sd_setImage(with: URL(string: entry.imageURL))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webViewController = WebViewController()
        webViewController.targetUrl = self.articles[indexPath.row].link
        webViewController.positionX = Int(self.articles[indexPath.row].positionX) ?? 0
        webViewController.positionY = Int(self.articles[indexPath.row].positionY) ?? 0
        self.navigationController!.pushViewController(webViewController , animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)) // assuming 40 height for footer.
        return footerView
    }
    
    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
}
