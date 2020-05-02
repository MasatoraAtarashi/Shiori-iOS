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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate, UISearchBarDelegate, UISearchResultsUpdating, TutorialDelegate, UIViewControllerPreviewingDelegate {
    
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
    
    var r: Int = UserDefaults.standard.integer(forKey: "r")
    var g: Int = UserDefaults.standard.integer(forKey: "g")
    var b: Int = UserDefaults.standard.integer(forKey: "b")
    
    @IBOutlet var bannerView: GADBannerView?
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    @IBOutlet weak var footerText1: UIBarButtonItem!
    @IBOutlet weak var footerText2: UIBarButtonItem!
    
    
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
                sender.title = NSLocalizedString("Show only unread", comment: "")
                getStoredDataFromUserDefault()
            } else {
                unreadMode = true
                sender.title = NSLocalizedString("Show all", comment: "")
                getStoredDataFromUserDefault()
            }
        }
        
    }
    
    //言語変更
    func changeViewLanguage() {
        //なんもないときのやつ
        text.text = NSLocalizedString("List is empty", comment: "")
        text2.text = NSLocalizedString("Adding articles is easy. Tap below to get started.", comment: "")
        button.setTitle(NSLocalizedString("Learn how to save", comment: ""), for: UIControl.State())
        button.sizeToFit()
        button.layer.cornerRadius = 10.0
        
        //フッターのボタン
        if !tableView.isEditing {
            bottomToolbarRightItem.title = NSLocalizedString("Edit", comment: "")
            if unreadMode {
                bottomToolbarLeftItem.title = NSLocalizedString("Show all", comment: "")
            } else {
                bottomToolbarLeftItem.title = NSLocalizedString("Show only unread", comment: "")
            }
        } else {
            bottomToolbarRightItem.title = NSLocalizedString("Done", comment: "")
            bottomToolbarLeftItem.title = NSLocalizedString("Delete", comment: "")
        }
    }
    
    @IBOutlet weak var bottomToolbarLeftItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbarRightItem: UIBarButtonItem!
    
    @IBAction func changeToEditMode(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            sender.title = NSLocalizedString("Edit", comment: "")
            if unreadMode {
                bottomToolbarLeftItem.title = NSLocalizedString("Show all", comment: "")
            } else {
                bottomToolbarLeftItem.title = NSLocalizedString("Show only unread", comment: "")
            }
            setEditing(false, animated: true)
        } else {
            sender.title = NSLocalizedString("Done", comment: "")
            bottomToolbarLeftItem.title = NSLocalizedString("Delete", comment: "")
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
        
        //起動時に言語を変更する
        changeViewLanguage()
        
        tableView.refreshControl = refreshCtl
        tableView.refreshControl?.addTarget(self, action: #selector(ViewController.getStoredDataFromUserDefault), for: .valueChanged)
        
//        検索
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = searchController
        
//        3dtouch
        self.registerForPreviewing(with: self, sourceView: tableView)

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        var bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.navigationController?.setToolbarHidden(false, animated: true)
//        footer color
        self.navigationController?.toolbar.barTintColor = bgColor
//        header color
        self.navigationController?.navigationBar.barTintColor = bgColor
//        背景
        tableView.backgroundColor = bgColor
        tableView.reloadData()

        if r == 0 || r == 60 {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!]
            text.textColor = UIColor.white
            text2.textColor = UIColor.white
//            フッターの文字の色
            footerText1.tintColor = UIColor.white
            footerText2.tintColor = UIColor.white
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!]
            text.textColor = UIColor.black
            text2.textColor = UIColor.black
            //            フッターの文字の色
            footerText1.tintColor = UIColor.black
            footerText2.tintColor = UIColor.black
        }
        
        changeDisplayAdvertisement()
        hiddenToolbarButtonEdit()
    }
    
//    広告表示
    func changeDisplayAdvertisement() {
        if UserDefaults.standard.bool(forKey: "isAdvertisementOn") {
            if bannerView != nil {
                self.view.addSubview(bannerView!)
                let constraints = [
                    bannerView!.centerXAnchor.constraint(equalTo: self.view!.centerXAnchor),
                    bannerView!.heightAnchor.constraint(equalToConstant: CGFloat(50)),
                    bannerView!.bottomAnchor.constraint(equalTo: (self.view.bottomAnchor), constant: CGFloat(-50)),
                ]
                NSLayoutConstraint.activate(constraints)
                let deviceData = getDeviceInfo()
                if deviceData == "Simulator" {
                    bannerView!.bottomAnchor.constraint(equalTo: (self.view.bottomAnchor), constant: CGFloat(-80)).isActive = true
                } else if deviceData == "iPhone 11" {
                    bannerView!.bottomAnchor.constraint(equalTo: (self.view.bottomAnchor), constant: CGFloat(-80)).isActive = true
                } else if deviceData == "iPhone X" {
                    bannerView!.bottomAnchor.constraint(equalTo: (self.view.bottomAnchor), constant: CGFloat(-80)).isActive = true
                }
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
            bottomToolbarRightItem.title = NSLocalizedString("Edit", comment: "")
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
        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        var bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        cell.backgroundColor = bgColor
        if r == 0 || r == 60 {
            cell.title.textColor = UIColor.white
            cell.subContent.textColor = UIColor.white
        } else {
            cell.title.textColor = UIColor.black
            cell.subContent.textColor = UIColor.lightGray
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
                readAction = SwipeAction(style: .default, title: NSLocalizedString("Mark as read", comment: "")) { action, indexPath in
                    self.haveReadCell(at: indexPath)
                }
            } else {
                readAction = SwipeAction(style: .default, title: NSLocalizedString("Unread", comment: "")) { action, indexPath in
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
            if searchController.isActive {
                let article = try readContext.fetch(fetchRequest)
                readContext.delete(searchResults[searchResults.count - indexPath.row - 1])
            } else {
                let article = try readContext.fetch(fetchRequest)
                readContext.delete(article[article.count - indexPath.row - 1])
            }
        } catch {
            print("Error")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getStoredDataFromUserDefault()
    }
    
    func haveReadCell(at indexPath: IndexPath) {
        
        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        if unreadMode {
            fetchRequest.predicate = NSPredicate(format: "haveRead = true")
        }
        do {
            let article = try readContext.fetch(fetchRequest)
            
            if searchController.isActive {
                let webViewController = WebViewController()
                print("Unkounko")
                if searchResults[searchResults.count - indexPath.row - 1].haveRead {
                    self.searchResults[indexPath.row].haveRead = false
                    searchResults[searchResults.count - indexPath.row - 1].haveRead = false
                } else {
                    self.searchResults[indexPath.row].haveRead = true
                    searchResults[searchResults.count - indexPath.row - 1].haveRead = true
                }
            } else {
                if article[article.count - indexPath.row - 1].haveRead {
                    self.articles[indexPath.row].haveRead = false
                    article[article.count - indexPath.row - 1].haveRead = false
                } else {
                    self.articles[indexPath.row].haveRead = true
                    article[article.count - indexPath.row - 1].haveRead = true
                }
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
    
//    3dtouch
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let webViewController = WebViewController()
        webViewController.targetUrl = self.articles[indexPath.row].link
        webViewController.positionX = Int(self.articles[indexPath.row].positionX ?? "0") ?? 0
        webViewController.positionY = Int(self.articles[indexPath.row].positionY ?? "0") ?? 0
        return webViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
//    長押し
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let previewProvider: () -> WebViewController? = { [unowned self] in
            let webViewController = WebViewController()
            webViewController.targetUrl = self.articles[indexPath.row].link
            webViewController.positionX = Int(self.articles[indexPath.row].positionX ?? "0") ?? 0
            webViewController.positionY = Int(self.articles[indexPath.row].positionY ?? "0") ?? 0
            return webViewController
        }
        
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let share = UIAction(title: "共有", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let shareText = self.articles[indexPath.row].title
                let shareWebsite: NSURL
                if let shareURL = URL(string: self.articles[indexPath.row].link!) {
                    shareWebsite = shareURL as NSURL
                } else {
                    return
                }
                
                let activityItems = [shareText, shareWebsite] as [Any]
                
                // 初期化処理
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [CustomActivity(title: shareText ?? "", url: shareWebsite as URL)])
                
                // UIActivityViewControllerを表示
                self.present(activityVC, animated: true, completion: nil)
            }

            return UIMenu(__title: "Edit..", image: nil, identifier: nil, children: [share])
        }

        return UIContextMenuConfiguration(identifier: nil,
        previewProvider: previewProvider, actionProvider: actionProvider)
    }
    
}

extension ViewController {
    func getDeviceInfo () -> String{
        var size : Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let code:String = String(cString:machine)

        let deviceCodeDic:[String:String] = [
            /* Simulator */
            "i386"      :"Simulator",
            "x86_64"    :"Simulator",
            /* iPod */
            "iPod1,1"   :"iPod Touch 1st",            // iPod Touch 1st Generation
            "iPod2,1"   :"iPod Touch 2nd",            // iPod Touch 2nd Generation
            "iPod3,1"   :"iPod Touch 3rd",            // iPod Touch 3rd Generation
            "iPod4,1"   :"iPod Touch 4th",            // iPod Touch 4th Generation
            "iPod5,1"   :"iPod Touch 5th",            // iPod Touch 5th Generation
            "iPod7,1"   :"iPod Touch 6th",            // iPod Touch 6th Generation
            /* iPhone */
            "iPhone1,1"   :"iPhone 2G",                 // iPhone 2G
            "iPhone1,2"   :"iPhone 3G",                 // iPhone 3G
            "iPhone2,1"   :"iPhone 3GS",                // iPhone 3GS
            "iPhone3,1"   :"iPhone 4",                  // iPhone 4 GSM
            "iPhone3,2"   :"iPhone 4",                  // iPhone 4 GSM 2012
            "iPhone3,3"   :"iPhone 4",                  // iPhone 4 CDMA For Verizon,Sprint
            "iPhone4,1"   :"iPhone 4S",                 // iPhone 4S
            "iPhone5,1"   :"iPhone 5",                  // iPhone 5 GSM
            "iPhone5,2"   :"iPhone 5",                  // iPhone 5 Global
            "iPhone5,3"   :"iPhone 5c",                 // iPhone 5c GSM
            "iPhone5,4"   :"iPhone 5c",                 // iPhone 5c Global
            "iPhone6,1"   :"iPhone 5s",                 // iPhone 5s GSM
            "iPhone6,2"   :"iPhone 5s",                 // iPhone 5s Global
            "iPhone7,1"   :"iPhone 6 Plus",             // iPhone 6 Plus
            "iPhone7,2"   :"iPhone 6",                  // iPhone 6
            "iPhone8,1"   :"iPhone 6S",                 // iPhone 6S
            "iPhone8,2"   :"iPhone 6S Plus",            // iPhone 6S Plus
            "iPhone8,4"   :"iPhone SE" ,                // iPhone SE
            "iPhone9,1"   :"iPhone 7",                  // iPhone 7 A1660,A1779,A1780
            "iPhone9,3"   :"iPhone 7",                  // iPhone 7 A1778
            "iPhone9,2"   :"iPhone 7 Plus",             // iPhone 7 Plus A1661,A1785,A1786
            "iPhone9,4"   :"iPhone 7 Plus",             // iPhone 7 Plus A1784
            "iPhone10,1"  :"iPhone 8",                  // iPhone 8 A1863,A1906,A1907
            "iPhone10,4"  :"iPhone 8",                  // iPhone 8 A1905
            "iPhone10,2"  :"iPhone 8 Plus",             // iPhone 8 Plus A1864,A1898,A1899
            "iPhone10,5"  :"iPhone 8 Plus",             // iPhone 8 Plus A1897
            "iPhone10,3"  :"iPhone X",                  // iPhone X A1865,A1902
            "iPhone10,6"  :"iPhone X",                  // iPhone X A1901
            "iPhone11,8"  :"iPhone XR",                 // iPhone XR A1984,A2105,A2106,A2108
            "iPhone11,2"  :"iPhone XS",                 // iPhone XS A2097,A2098
            "iPhone11,4"  :"iPhone XS Max",             // iPhone XS Max A1921,A2103
            "iPhone11,6"  :"iPhone XS Max",             // iPhone XS Max A2104

            /* iPad */
            "iPad1,1"   :"iPad 1 ",                     // iPad 1
            "iPad2,1"   :"iPad 2 WiFi",                 // iPad 2
            "iPad2,2"   :"iPad 2 Cell",                 // iPad 2 GSM
            "iPad2,3"   :"iPad 2 Cell",                 // iPad 2 CDMA (Cellular)
            "iPad2,4"   :"iPad 2 WiFi",                 // iPad 2 Mid2012
            "iPad2,5"   :"iPad Mini WiFi",              // iPad Mini WiFi
            "iPad2,6"   :"iPad Mini Cell",              // iPad Mini GSM (Cellular)
            "iPad2,7"   :"iPad Mini Cell",              // iPad Mini Global (Cellular)
            "iPad3,1"   :"iPad 3 WiFi",                 // iPad 3 WiFi
            "iPad3,2"   :"iPad 3 Cell",                 // iPad 3 CDMA (Cellular)
            "iPad3,3"   :"iPad 3 Cell",                 // iPad 3 GSM (Cellular)
            "iPad3,4"   :"iPad 4 WiFi",                 // iPad 4 WiFi
            "iPad3,5"   :"iPad 4 Cell",                 // iPad 4 GSM (Cellular)
            "iPad3,6"   :"iPad 4 Cell",                 // iPad 4 Global (Cellular)
            "iPad4,1"   :"iPad Air WiFi",               // iPad Air WiFi
            "iPad4,2"   :"iPad Air Cell",               // iPad Air Cellular
            "iPad4,3"   :"iPad Air China",              // iPad Air ChinaModel
            "iPad4,4"   :"iPad Mini 2 WiFi",            // iPad mini 2 WiFi
            "iPad4,5"   :"iPad Mini 2 Cell",            // iPad mini 2 Cellular
            "iPad4,6"   :"iPad Mini 2 China",           // iPad mini 2 ChinaModel
            "iPad4,7"   :"iPad Mini 3 WiFi",            // iPad mini 3 WiFi
            "iPad4,8"   :"iPad Mini 3 Cell",            // iPad mini 3 Cellular
            "iPad4,9"   :"iPad Mini 3 China",           // iPad mini 3 ChinaModel
            "iPad5,1"   :"iPad Mini 4 WiFi",            // iPad Mini 4 WiFi
            "iPad5,2"   :"iPad Mini 4 Cell",            // iPad Mini 4 Cellular
            "iPad5,3"   :"iPad Air 2 WiFi",             // iPad Air 2 WiFi
            "iPad5,4"   :"iPad Air 2 Cell",             // iPad Air 2 Cellular
            "iPad6,3"   :"iPad Pro 9.7inch WiFi",       // iPad Pro 9.7inch WiFi
            "iPad6,4"   :"iPad Pro 9.7inch Cell",       // iPad Pro 9.7inch Cellular
            "iPad6,7"   :"iPad Pro 12.9inch WiFi",      // iPad Pro 12.9inch WiFi
            "iPad6,8"   :"iPad Pro 12.9inch Cell",      // iPad Pro 12.9inch Cellular
            "iPad6,11"  :"iPad 5th",                    // iPad 5th Generation WiFi
            "iPad6,12"  :"iPad 5th",                    // iPad 5th Generation Cellular
            "iPad7,1"   :"iPad Pro 12.9inch 2nd",       // iPad Pro 12.9inch 2nd Generation WiFi
            "iPad7,2"   :"iPad Pro 12.9inch 2nd",       // iPad Pro 12.9inch 2nd Generation Cellular
            "iPad7,3"   :"iPad Pro 10.5inch",           // iPad Pro 10.5inch A1701 WiFi
            "iPad7,4"   :"iPad Pro 10.5inch",           // iPad Pro 10.5inch A1709 Cellular
            "iPad7,5"   :"iPad 6th",                    // iPad 6th Generation WiFi
            "iPad7,6"   :"iPad 6th",                     // iPad 6th Generation Cellular
            "iPad8,1"   :"iPad Pro 11inch WiFi",        // iPad Pro 11inch WiFi
            "iPad8,2"   :"iPad Pro 11inch WiFi",        // iPad Pro 11inch WiFi
            "iPad8,3"   :"iPad Pro 11inch Cell",        // iPad Pro 11inch Cellular
            "iPad8,4"   :"iPad Pro 11inch Cell",        // iPad Pro 11inch Cellular
            "iPad8,5"   :"iPad Pro 12.9inch WiFi",      // iPad Pro 12.9inch WiFi
            "iPad8,6"   :"iPad Pro 12.9inch WiFi",      // iPad Pro 12.9inch WiFi
            "iPad8,7"   :"iPad Pro 12.9inch Cell",      // iPad Pro 12.9inch Cellular
            "iPad8,8"   :"iPad Pro 12.9inch Cell",      // iPad Pro 12.9inch Cellular
            "iPad11,1"  :"iPad Mini 5th WiFi",          // iPad mini 5th WiFi
            "iPad11,2"  :"iPad Mini 5th Cell",          // iPad mini 5th Cellular
            "iPad11,3"  :"iPad Air 3rd WiFi",           // iPad Air 3rd generation WiFi
            "iPad11,4"  :"iPad Air 3rd Cell"            // iPad Air 3rd generation Cellular
        ]

        if let deviceName = deviceCodeDic[code] {
            return deviceName
        }else{
            if code.range(of: "iPod") != nil {
                return "iPod Touch"
            }else if code.range(of: "iPad") != nil {
                return "iPad"
            }else if code.range(of: "iPhone") != nil {
                return "iPhone"
            }else{
                return "unknownDevice"
            }
        }
    }
}
