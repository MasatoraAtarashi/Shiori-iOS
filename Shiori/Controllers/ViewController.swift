//
//  ViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit
import CoreData
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate, UISearchBarDelegate, UISearchResultsUpdating, TutorialDelegate {
    
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"
    
    var pageTitle: String = ""
    var link: String = ""
    var positionX: Int = 0
    var positionY: Int = 0
    
    var articles: [Article] = []
    var searchResults:[Article] = []
    
    var searchController = UISearchController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var unreadMode: Bool = false
    
    @IBOutlet var bannerView: GADBannerView?
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func goToTutorialPage(_ sender: Any) {
        performSegue(withIdentifier: "TutorialSegue", sender: nil)
    }
    
    @IBAction func goToSettingPage(_ sender: Any) {
        performSegue(withIdentifier: "SettingSegue", sender: nil)
    }

    @IBAction func changeViewForReaded(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            if tableView.indexPathsForSelectedRows != nil {
                if let sortedIndexPaths = tableView.indexPathsForSelectedRows?.sorted(by: { $0.row > $1.row }) {
                    for indexPathList in sortedIndexPaths {
                        deleteCell(at: indexPathList)
                    }
                    changeToEditMode(bottomToolbarRightItem)
                    hiddenToolbarButtonEdit()
                    
                }
            }
        } else {
            if unreadMode {
                unreadMode = false
                sender.title = "未読のみ表示"
                getStoredDataFromUserDefault()
            } else {
                unreadMode = true
                sender.title = "すべて表示"
                getStoredDataFromUserDefault()
            }
        }
        
    }
    
    @IBOutlet weak var bottomToolbarLeftItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbarRightItem: UIBarButtonItem!
    
    @IBAction func changeToEditMode(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            sender.title = "編集"
            if unreadMode {
                bottomToolbarLeftItem.title = "すべて表示"
            } else {
                bottomToolbarLeftItem.title = "未読のみ表示"
            }
            setEditing(false, animated: true)
        } else {
            sender.title = "完了"
            bottomToolbarLeftItem.title = "削除"
            setEditing(true, animated: true)
        }
    }
    
    fileprivate let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView?.adUnitID = "ca-app-pub-3503963096402837/1680525403"
        bannerView?.rootViewController = self
        bannerView?.load(GADRequest())
        changeDisplayAdvertisement()
        
        self.tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        
        // Do any additional setup after loading the view.
        getStoredDataFromUserDefault()
        
        tableView.refreshControl = refreshCtl
        tableView.refreshControl?.addTarget(self, action: #selector(ViewController.getStoredDataFromUserDefault), for: .valueChanged)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.toolbar.barTintColor = UIColor.white
        changeDisplayAdvertisement()
        hiddenToolbarButtonEdit()
    }
    
    func changeDisplayAdvertisement() {
        if UserDefaults.standard.bool(forKey: "isAdvertisementOn") {
            if bannerView != nil {
                self.view.addSubview(bannerView!)
                let constraints = [
                    bannerView!.centerXAnchor.constraint(equalTo: self.view!.centerXAnchor),
//                    bannerView!.widthAnchor.constraint(equalToConstant: CGFloat(320)),
                    bannerView!.heightAnchor.constraint(equalToConstant: CGFloat(50)),
                    bannerView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: CGFloat(-50))
                ]
                NSLayoutConstraint.activate(constraints)
                self.view.bringSubviewToFront(bannerView!)
            }
        } else {
            if bannerView != nil {
                bannerView!.removeFromSuperview()
            }
        }
        
    }

    
    func hiddenToolbarButtonEdit() {
        if self.articles.count == 0 {
            bottomToolbarRightItem.isEnabled = false
            bottomToolbarRightItem.title = ""
        } else if self.articles.count != 0 && !tableView.isEditing {
            bottomToolbarRightItem.isEnabled = true
            bottomToolbarRightItem.title = "編集"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenRect = UIScreen.main.bounds
        tableView.frame = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
    }
    
    @objc func getStoredDataFromUserDefault() {
        self.articles = []
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
        var storedArray: [Dictionary<String, String>] = sharedDefaults.array(forKey: self.keyName) as? [Dictionary<String, String>] ?? []
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for result in storedArray {
            let article = Article(context: context)
            article.title = result["title"]!
            article.link = result["url"]!
            article.imageURL = result["image"]!
            article.positionX = result["positionX"]!
            article.positionY = result["positionY"]!
            article.date = result["date"]!
            article.haveRead = Bool(result["haveRead"]!)!
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        
        sharedDefaults.set([], forKey: self.keyName)
        
        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
            if unreadMode {
                fetchRequest.predicate = NSPredicate(format: "haveRead = true")
            }
            self.articles = try readContext.fetch(fetchRequest)
            
        } catch {
            print("Error")
        }
        
//        for result in storedArray {
//            if unreadMode {
//                if !Bool(result["haveRead"]!)! {
//                    continue
//                }
//            }
//            self.articles.append(Entry(
//                title: result["title"]!,
//                link: result["url"]!,
//                imageURL: result["image"]!,
//                positionX: result["positionX"]!,
//                positionY: result["positionY"]!,
//                date: result["date"]!,
//                haveRead: Bool(result["haveRead"]!)!
//            ))
//        }
        articles.reverse()
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        hiddenToolbarButtonEdit()
        
        if articles.count == 0 {
            self.view.bringSubviewToFront(text)
            self.view.bringSubviewToFront(text2)
            self.view.bringSubviewToFront(button)
            button.backgroundColor = UIColor.init(red: 27/255, green: 156/255, blue: 252/255, alpha: 1)
            text.isHidden = false
            text2.isHidden = false
            button.isHidden = false
            button.isEnabled = true
        } else {
            self.view.bringSubviewToFront(text)
            self.view.bringSubviewToFront(text2)
            self.view.bringSubviewToFront(button)
            text.isHidden = true
            text2.isHidden = true
            button.isHidden = true
            button.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        } else {
            return articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath as IndexPath) as! FeedTableViewCell
        if searchController.isActive {
            let entry = self.searchResults[indexPath.row]
            cell.delegate = self
            cell.title.text = entry.title
            cell.subContent.text = entry.link
            cell.thumbnail.sd_setImage(with: URL(string: entry.imageURL ?? ""))
        } else {
            let entry = self.articles[indexPath.row]
            cell.delegate = self
            cell.title.text = entry.title
            cell.subContent.text = entry.link
            cell.thumbnail.sd_setImage(with: URL(string: entry.imageURL ?? ""))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            if searchController.isActive {
                let webViewController = WebViewController()
                webViewController.targetUrl = self.searchResults[indexPath.row].link
                webViewController.positionX = Int(self.searchResults[indexPath.row].positionX ?? "0") ?? 0
                webViewController.positionY = Int(self.searchResults[indexPath.row].positionY ?? "0") ?? 0
                self.navigationController!.pushViewController(webViewController , animated: true)
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            } else {
                let webViewController = WebViewController()
                webViewController.targetUrl = self.articles[indexPath.row].link
                webViewController.positionX = Int(self.articles[indexPath.row].positionX ?? "0") ?? 0
                webViewController.positionY = Int(self.articles[indexPath.row].positionY ?? "0") ?? 0
                self.navigationController!.pushViewController(webViewController , animated: true)
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            }
        }
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.deleteCell(at: indexPath)
            }
            
            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")
            
            return [deleteAction]
        } else {
            let readAction: SwipeAction
            if articles[indexPath.row].haveRead {
                readAction = SwipeAction(style: .default, title: "既読にする") { action, indexPath in
                    self.haveReadCell(at: indexPath)
                }
            } else {
                readAction = SwipeAction(style: .default, title: "未読にする") { action, indexPath in
                    self.haveReadCell(at: indexPath)
                }
            }
            // customize the action appearance
            readAction.image = UIImage(named: "mail")
            readAction.backgroundColor = UIColor.init(red: 27/255, green: 156/255, blue: 252/255, alpha: 1)
            
            return [readAction]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }
    
    func deleteCell(at indexPath: IndexPath) {
        self.articles.remove(at: indexPath.row)
        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        if unreadMode {
            fetchRequest.predicate = NSPredicate(format: "haveRead = true")
        }
        do {
            let article = try readContext.fetch(fetchRequest)
            readContext.delete(article[article.count - indexPath.row - 1])
        } catch {
            print("Error")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getStoredDataFromUserDefault()
    }
    
    func haveReadCell(at indexPath: IndexPath) {
//        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//        var storedArray: [Dictionary<String, String>] = sharedDefaults.array(forKey: self.keyName) as? [Dictionary<String, String>] ?? []
//        if storedArray[indexPath.row]["haveRead"] == "true" {
//            self.articles[indexPath.row].haveRead = false
//            storedArray[indexPath.row]["haveRead"] = "false"
//        } else {
//            self.articles[indexPath.row].haveRead = true
//            storedArray[indexPath.row]["haveRead"] = "true"
//        }
//        sharedDefaults.set(storedArray, forKey: self.keyName)
        
        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        if unreadMode {
            fetchRequest.predicate = NSPredicate(format: "haveRead = true")
        }
        do {
            let article = try readContext.fetch(fetchRequest)
            if article[article.count - indexPath.row - 1].haveRead {
                self.articles[indexPath.row].haveRead = false
                article[article.count - indexPath.row - 1].haveRead = false
            } else {
                self.articles[article.count - indexPath.row - 1].haveRead = true
                article[article.count - indexPath.row - 1].haveRead = true
            }
        } catch {
            print("Error")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getStoredDataFromUserDefault()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        tableView.allowsMultipleSelectionDuringEditing = true
        //override前の処理を継続してさせる
        super.setEditing(editing, animated: animated)
        //tableViewの編集モードを切り替える
        tableView.isEditing = editing //editingはBool型でeditButtonに依存する変数
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.searchResults = articles.filter{
            // 大文字と小文字を区別せずに検索
            $0.title?.lowercased().contains(searchController.searchBar.text!.lowercased()) ?? true
        }
        self.tableView.reloadData()
    }

    var viewControllerNameFrom: String = ""
    func viewControllerFrom(viewController: String) {
        viewControllerNameFrom = viewController
    }
}