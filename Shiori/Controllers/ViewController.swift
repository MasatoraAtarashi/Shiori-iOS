//
//  ViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import CoreData
import Firebase
import GoogleMobileAds
import NVActivityIndicatorView
import SDWebImage
import SwiftMessages
import SwipeCellKit
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    SwipeTableViewCellDelegate,
    UISearchBarDelegate, UISearchResultsUpdating, TutorialDelegate
{

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    var contentListManager = ContentListManager()
    var contentManager = ContentManager()

    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"

    var pageTitle: String = ""
    var link: String = ""
    var positionX: Int = 0
    var positionY: Int = 0

    //    var articles: [Article] = []
    var contentList: [Content] = []
    //    var searchResults: [Article] = []

    var searchController = UISearchController()

    // フォルダ
    var folderInt: String = NSLocalizedString("Home", comment: "")
    var folderId: Int = const.HomeFolderId

    var r: Int = UserDefaults.standard.integer(forKey: "r")
    var g: Int = UserDefaults.standard.integer(forKey: "g")
    var b: Int = UserDefaults.standard.integer(forKey: "b")

    // MARK: IBOutlets
    @IBOutlet weak var tutorialTextLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bannerView: GADBannerView?

    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var text2: UILabel!

    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var footerText1: UIBarButtonItem!
    @IBOutlet weak var footerText2: UIBarButtonItem!

    @IBOutlet weak var bottomToolbarLeftItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbarRightItem: UIBarButtonItem!

    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    fileprivate let refreshCtl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()

        // delegateを設定
        contentListManager.delegate = self
        contentManager.delegate = self

        // 広告
        initAdvertisement()
        self.tableView.register(
            UINib(nibName: "FeedTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeedTableViewCell")
        // ローカルストレージからコンテンツを取得
        // getStoredDataFromUserDefault()

        // インジケータを作成
        initIndicator()
        // インジケータを表示
        startIndicator()
        // コンテンツ一覧を取得
        contentListManager.fetchContentList()

        // コンテンツ一覧を表示
        // renderContentList()

        // 起動時に言語を変更する
        changeViewLanguage()
        // 記事を更新するときにクルクルするやつ
        initRefreshController()
        // 検索
        initSearchController()
        tutorialTextLabel.text = "記事を追加するのは簡単です。\n以下をタップして始めましょう。"
    }

    override func viewWillAppear(_ animated: Bool) {
        // 背景色を設定
        changeBackgroundColor()
        // 広告表示
        changeDisplayAdvertisement()
        // フッターのボタンの表示切り替え
        hiddenToolbarButtonEdit()

        // NOTE: SubTableViewControllerから戻ってきたときの処理。!= nilという条件はあんまりよくない。本当は == SubTableViewControllerとかでやりたいけど、どうやるかわからない
        if navigationController?.presentedViewController != nil {
            loadFolderContentList()
        }
    }

    // レイアウト処理終了時の処理
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let screenRect = UIScreen.main.bounds
        tableView.frame = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
    }

    // MARK: IBActions
    // チュートリアル画面に遷移
    @IBAction func goToTutorialPage(_ sender: Any) {
        performSegue(withIdentifier: "TutorialSegue", sender: nil)
    }

    // 設定画面に遷移
    @IBAction func goToSettingPage(_ sender: Any) {
        performSegue(withIdentifier: "SettingSegue", sender: nil)
    }

    // 一括編集モードで選択した記事を削除する
    @IBAction func deleteSelectedArticles(_ sender: UIBarButtonItem) {
        if !tableView.isEditing || tableView.indexPathsForSelectedRows == nil { return }
        if let sortedIndexPaths = tableView.indexPathsForSelectedRows?.sorted(by: {
            $0.row > $1.row
        }) {
            for indexPathList in sortedIndexPaths {
                deleteCell(at: indexPathList)
            }
            changeToEditMode(bottomToolbarRightItem)
            hiddenToolbarButtonEdit()
        }
    }

    // 一括編集モードにする
    @IBAction func changeToEditMode(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            sender.title = NSLocalizedString("Edit", comment: "")
            hiddenToolbarButtonEdit()
            setEditing(false, animated: true)
        } else {
            sender.title = NSLocalizedString("Done", comment: "")

            bottomToolbarLeftItem.isEnabled = true
            bottomToolbarLeftItem.image = UIImage(systemName: "trash")
            setEditing(true, animated: true)
        }
    }

    // MARK: UITableViewDelegate
    // セルの数の設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }

    // セルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "FeedTableViewCell", for: indexPath as IndexPath)
            as! FeedTableViewCell

        let content = contentList[indexPath.row]
        cell.delegate = self
        cell.title.text = content.title
        cell.subContent.text = content.url
        cell.date.text = content.createdAt
        cell.thumbnail.sd_setImage(with: URL(string: content.thumbnailImgUrl))

        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        let bgColor: UIColor = UIColor(
            red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        cell.backgroundColor = bgColor
        if r == 0 || r == 60 {
            cell.title.textColor = UIColor.white
            cell.subContent.textColor = UIColor.white
            cell.date.textColor = UIColor.white
        } else {
            cell.title.textColor = UIColor.black
            cell.subContent.textColor = UIColor.lightGray
            cell.date.textColor = UIColor.lightGray
        }
        return cell
    }

    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing { return }
        let webViewController = WebViewController()
        webViewController.targetUrl = contentList[indexPath.row].url
        webViewController.positionX = contentList[indexPath.row].scrollPositionX
        webViewController.positionY = contentList[indexPath.row].scrollPositionY
        webViewController.videoPlaybackPosition = contentList[indexPath.row].videoPlaybackPosition
        self.navigationController!.pushViewController(webViewController, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // フッターの見た目を設定
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        return footerView
    }

    // set height for footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    // swipeしたときの処理
    func tableView(
        _ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> [SwipeAction]? {
        if orientation == .right {
            //                let deleteAction = SwipeAction(
            //                    style: .destructive, title: NSLocalizedString("Delete", comment: "")
            //                ) { _, indexPath in
            //                    self.deleteCell(at: indexPath)
            //                }
            //                deleteAction.image = UIImage(systemName: "trash.fill")
            //
            //                // お気に入り
            //                var favoriteAction: SwipeAction
            //                let _: NSFetchRequest<Article> = Article.fetchRequest()
            //
            //                let targetArticles = searchController.isActive ? searchResults : articles
            //                let filteredArticles = targetArticles.filter({
            //                    ($0.folderInt ?? [NSLocalizedString("Home", comment: "")]).contains(folderInt)
            //                })
            //
            //                if filteredArticles[indexPath.row].folderInt?.contains(
            //                    NSLocalizedString("Liked", comment: "")) ?? false
            //                {
            //                    favoriteAction = SwipeAction(
            //                        style: .default, title: NSLocalizedString("Cancel", comment: "")
            //                    ) { _, indexPath in
            //                        self.favoriteCell(at: indexPath)
            //                    }
            //                    favoriteAction.image = UIImage(systemName: "heart.fill")
            //                } else {
            //                    favoriteAction = SwipeAction(
            //                        style: .default, title: NSLocalizedString("Liked", comment: "")
            //                    ) { _, indexPath in
            //                        self.favoriteCell(at: indexPath)
            //                    }
            //                    favoriteAction.image = UIImage(systemName: "heart")
            //                }
            //                favoriteAction.backgroundColor = UIColor.init(
            //                    red: 255 / 255, green: 165 / 255, blue: 0 / 255, alpha: 1)
            //
            //                let folderAction = SwipeAction(
            //                    style: .default, title: NSLocalizedString("Add", comment: "")
            //                ) { _, indexPath in
            //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                    let vc =
            //                        storyboard.instantiateViewController(withIdentifier: "myVCID")
            //                        as! UINavigationController
            //                    let selectFolderTableViewController =
            //                        vc.viewControllers.first as! SelectFolderTableViewController
            //                    selectFolderTableViewController.selectedIndexPath = indexPath.row
            //                    let _: NSFetchRequest<Article> = Article.fetchRequest()
            //
            //                    let targetArticles =
            //                        self.searchController.isActive ? self.searchResults : self.articles
            //                    let filteredArticles = targetArticles.filter({
            //                        ($0.folderInt ?? [NSLocalizedString("Home", comment: "")]).contains(
            //                            self.folderInt)
            //                    })
            //                    selectFolderTableViewController.articles = filteredArticles
            //                    self.present(vc, animated: true)
            //                }
            //                folderAction.image = UIImage(systemName: "folder.fill")
            //                folderAction.backgroundColor = UIColor.init(
            //                    red: 176 / 255, green: 196 / 255, blue: 222 / 255, alpha: 1)

            // 削除アクション
            let deleteAction = SwipeAction(
                style: .destructive, title: NSLocalizedString("Delete", comment: "")
            ) { _, indexPath in
                self.deleteCell(at: indexPath)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")

            // お気に入りアクション
            var favoriteAction: SwipeAction

            if contentList[indexPath.row].liked ?? false {
                favoriteAction = SwipeAction(
                    style: .default, title: NSLocalizedString("Cancel", comment: "")
                ) { _, indexPath in
                    self.unFavoriteCell(at: indexPath)
                }
                favoriteAction.image = UIImage(systemName: "heart.fill")
            } else {
                favoriteAction = SwipeAction(
                    style: .default, title: NSLocalizedString("Liked", comment: "")
                ) { _, indexPath in
                    self.favoriteCell(at: indexPath)
                }
                favoriteAction.image = UIImage(systemName: "heart")
            }
            favoriteAction.backgroundColor = UIColor.init(
                red: 255 / 255, green: 165 / 255, blue: 0 / 255, alpha: 1)

            //                let folderAction = SwipeAction(
            //                    style: .default, title: NSLocalizedString("Add", comment: "")
            //                ) { _, indexPath in
            //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                    let vc =
            //                        storyboard.instantiateViewController(withIdentifier: "myVCID")
            //                        as! UINavigationController
            //                    let selectFolderTableViewController =
            //                        vc.viewControllers.first as! SelectFolderTableViewController
            //                    selectFolderTableViewController.selectedIndexPath = indexPath.row
            //                    let _: NSFetchRequest<Article> = Article.fetchRequest()
            //
            //                    let targetArticles =
            //                        self.searchController.isActive ? self.searchResults : self.articles
            //                    let filteredArticles = targetArticles.filter({
            //                        ($0.folderInt ?? [NSLocalizedString("Home", comment: "")]).contains(
            //                            self.folderInt)
            //                    })
            //                    selectFolderTableViewController.articles = filteredArticles
            //                    self.present(vc, animated: true)
            //                }
            //                folderAction.image = UIImage(systemName: "folder.fill")
            //                folderAction.backgroundColor = UIColor.init(
            //                    red: 176 / 255, green: 196 / 255, blue: 222 / 255, alpha: 1)
            //                return [deleteAction, favoriteAction, folderAction]
            return [deleteAction, favoriteAction]
        } else {
            return []
        }
    }

    // 完全にスワイプすると記事を削除する
    func tableView(
        _ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }

    //    長押し
    @available(iOS 13.0, *)
    func tableView(
        _ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let previewProvider: () -> WebViewController? = { [unowned self] in
            let webViewController = WebViewController()
            webViewController.targetUrl = contentList[indexPath.row].url
            webViewController.positionX = contentList[indexPath.row].scrollPositionX
            webViewController.positionY = contentList[indexPath.row].scrollPositionY
            return webViewController
        }

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let share = UIAction(title: "共有", image: UIImage(systemName: "square.and.arrow.up")) {
                _ in
                var shareText: String
                var shareWebsite: NSURL
                shareText = self.contentList[indexPath.row].title
                if let shareURL = URL(string: self.contentList[indexPath.row].url) {
                    shareWebsite = shareURL as NSURL
                } else {
                    return
                }
                let activityItems = [shareText, shareWebsite] as [Any]

                // 初期化処理
                let activityVC = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: [
                        CustomActivity(title: shareText, url: shareWebsite as URL)
                    ])

                // UIActivityViewControllerを表示
                self.present(activityVC, animated: true, completion: nil)
            }

            return UIMenu(title: "Edit..", image: nil, identifier: nil, children: [share])
        }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: previewProvider, actionProvider: actionProvider)
    }

    // MARK: UISearchBarDelegate
    // 検索
    func updateSearchResults(for searchController: UISearchController) {
        contentListManager.fetchContentList(q: searchController.searchBar.text ?? "")
    }

    // MARK: Other Methods
    // 広告
    func initAdvertisement() {
        bannerView?.adUnitID = "ca-app-pub-3503963096402837/1680525403"
        bannerView?.rootViewController = self
        bannerView?.load(GADRequest())
        changeDisplayAdvertisement()
    }

    // 広告表示
    func changeDisplayAdvertisement() {
        if UserDefaults.standard.bool(forKey: "isAdvertisementOn") {
            if bannerView != nil {
                self.view.addSubview(bannerView!)
                let constraints = [
                    bannerView!.centerXAnchor.constraint(equalTo: self.view!.centerXAnchor),
                    bannerView!.heightAnchor.constraint(equalToConstant: CGFloat(50)),
                    bannerView!.bottomAnchor.constraint(
                        equalTo: (self.view.bottomAnchor), constant: CGFloat(-50)),
                ]
                NSLayoutConstraint.activate(constraints)
                let deviceData = getDeviceInfo()
                if deviceData == "Simulator" {
                    bannerView!.bottomAnchor.constraint(
                        equalTo: (self.view.bottomAnchor), constant: CGFloat(-30)
                    ).isActive = true
                } else if deviceData == "iPhone 11" {
                    bannerView!.bottomAnchor.constraint(
                        equalTo: (self.view.bottomAnchor), constant: CGFloat(-80)
                    ).isActive = true
                } else if deviceData == "iPhone X" {
                    bannerView!.bottomAnchor.constraint(
                        equalTo: (self.view.bottomAnchor), constant: CGFloat(-80)
                    ).isActive = true
                } else if deviceData == "iPhone SE" {
                    bannerView!.bottomAnchor.constraint(
                        equalTo: (self.view.bottomAnchor), constant: CGFloat(-30)
                    ).isActive = true
                }
                self.view.bringSubviewToFront(bannerView!)
            }
        } else {
            if bannerView != nil {
                bannerView!.removeFromSuperview()
            }
        }

    }

    // 記事を更新するときにクルクルするやつ
    func initRefreshController() {
        tableView.refreshControl = refreshCtl
        tableView.refreshControl?.addTarget(
            self, action: #selector(ViewController.refresh), for: .valueChanged
        )
        tableView.refreshControl?.attributedTitle = NSAttributedString(
            string: NSLocalizedString("Pull to refresh", comment: ""))
    }

    // tableView更新
    @objc func refresh() {
        contentListManager.fetchContentList()
    }

    // 検索
    func initSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = searchController
    }

    // インジケータ
    func initIndicator() {
        tableView.addSubview(const.activityIndicatorView)
        tableView.bringSubviewToFront(const.activityIndicatorView)
        const.activityIndicatorView.center = tableView.center
    }

    func startIndicator() {
        const.activityIndicatorView.startAnimating()
    }

    func stopIndicator() {
        const.activityIndicatorView.stopAnimating()
    }

    // 背景色を設定
    func changeBackgroundColor() {
        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        let bgColor: UIColor = UIColor(
            red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.navigationController?.setToolbarHidden(false, animated: true)
        //        footer color
        self.navigationController?.toolbar.barTintColor = bgColor
        //        header color
        self.navigationController?.navigationBar.barTintColor = bgColor

        //        背景
        tableView.backgroundColor = bgColor
        tableView.reloadData()

        if r == 0 || r == 60 {
            self.navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!,
            ]
            text.textColor = UIColor.white
            text2.textColor = UIColor.white
            //            フッターの文字の色
            footerText1.tintColor = UIColor.white
            footerText2.tintColor = UIColor.white
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Baskerville-Bold", size: 22)!,
            ]
            text.textColor = UIColor.black
            text2.textColor = UIColor.black
            //            フッターの文字の色
            footerText1.tintColor = UIColor.black
            footerText2.tintColor = UIColor.black
        }
    }

    // フッターのボタンの表示切り替え
    func hiddenToolbarButtonEdit() {
        if contentList.count == 0 {
            bottomToolbarRightItem.isEnabled = false
            bottomToolbarRightItem.title = ""
        } else {
            if tableView.isEditing {
                bottomToolbarLeftItem.isEnabled = false
                bottomToolbarLeftItem.image = nil
            } else {
                bottomToolbarRightItem.isEnabled = true
                bottomToolbarRightItem.title = NSLocalizedString("Edit", comment: "")
            }
        }
    }

    // フォルダ内コンテンツを取得して表示する
    func loadFolderContentList() {
        startIndicator()
        if folderId == const.HomeFolderId {
            contentListManager.fetchContentList()
        } else if folderId == const.LikedFolderId {
            contentListManager.fetchContentList(liked: true)
        } else {
            contentListManager.fetchFolderContentList(folderId: folderId)
        }
    }

    // TODO: 削除
    // NOTE: このコードは後で参考にするためとっておく
    // ローカルに保存した記事を取得する
    @objc func getStoredDataFromUserDefault() {
        //        self.articles = []
        //        let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
        //        let storedArray: [[String: String]] =
        //            sharedDefaults.array(forKey: self.keyName) as? [[String: String]] ?? []
        //
        //        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        //            .viewContext
        //
        //        for result in storedArray {
        //            let article = Article(context: context)
        //            article.title = result["title"]!
        //            article.link = result["url"]!
        //            article.imageURL = result["image"]!
        //            article.positionX = result["positionX"]!
        //            article.positionY = result["positionY"]!
        //            article.date = result["date"]!
        //            article.videoPlaybackPosition = result["videoPlaybackPosition"]
        //            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //        }
        //
        //        sharedDefaults.set([], forKey: self.keyName)
        //
        //        let readContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        //            .viewContext
        //        do {
        //            let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        //            self.articles = try readContext.fetch(fetchRequest)
        //        } catch {
        //            print("Error")
        //        }
        //
        //        articles.reverse()
    }

    // コンテンツ一覧を表示
    func renderContentList() {
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        hiddenToolbarButtonEdit()
        if contentList.count == 0 {
            self.view.bringSubviewToFront(text)
            self.view.bringSubviewToFront(text2)
            self.view.bringSubviewToFront(button)
            button.backgroundColor = UIColor.init(
                red: 27 / 255, green: 156 / 255, blue: 252 / 255, alpha: 1)
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

    // 記事をお気に入りに登録
    func favoriteCell(at indexPath: IndexPath) {
        var contentRequest = contentList[indexPath.row]
        contentRequest.liked = true
        contentManager.putContent(contentId: contentList[indexPath.row].id, content: contentRequest)
    }

    // 記事のお気に入りを解除
    func unFavoriteCell(at indexPath: IndexPath) {
        var contentRequest = contentList[indexPath.row]
        contentRequest.liked = false
        contentManager.putContent(contentId: contentList[indexPath.row].id, content: contentRequest)
    }

    // TODO: リファクタリング
    // 記事をフォルダに追加
    func addArticleToFolder(_ ArticleindexPathRow: Int, _ folderName: String) {
        //        var alreadyAdded: Bool
        //        let _: NSFetchRequest<Article> = Article.fetchRequest()
        //
        //        let targetArticles = searchController.isActive ? searchResults : articles
        //        let filteredArticles = targetArticles.filter({
        //            ($0.folderInt ?? [NSLocalizedString("Home", comment: "")]).contains(folderInt)
        //        })
        //
        //        if filteredArticles[ArticleindexPathRow].folderInt == nil {
        //            filteredArticles[ArticleindexPathRow].folderInt = [
        //                NSLocalizedString("Home", comment: "")
        //            ]
        //        }
        //
        //        if filteredArticles[ArticleindexPathRow].folderInt!.contains(folderName) {
        //            filteredArticles[ArticleindexPathRow].folderInt?.remove(
        //                at: filteredArticles[ArticleindexPathRow].folderInt!.firstIndex(of: folderName)!
        //            )
        //            alreadyAdded = true
        //        } else {
        //            filteredArticles[ArticleindexPathRow].folderInt?.append(folderName)
        //            alreadyAdded = false
        //        }
        //
        //        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //        getStoredDataFromUserDefault()
        //        showPopUp(alreadyAdded)
    }

    // ポップアップを表示
    func showPopUp(_ alreadyAdded: Bool) {
        let success = MessageView.viewFromNib(layout: .cardView)
        if alreadyAdded {
            success.configureTheme(.error)
            success.configureContent(
                title: "Delete", body: NSLocalizedString("Deleted from folder", comment: ""))
        } else {
            success.configureTheme(.success)
            success.configureContent(
                title: "Success", body: NSLocalizedString("Added", comment: ""))
        }
        success.configureDropShadow()
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        SwiftMessages.show(config: successConfig, view: success)
    }

    // tableViewの編集モードを切り替える
    override func setEditing(_ editing: Bool, animated: Bool) {
        tableView.allowsMultipleSelectionDuringEditing = true
        // override前の処理を継続してさせる
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing  // editingはBool型でeditButtonに依存する変数
    }

    // 何のコードかわからない
    var viewControllerNameFrom: String = ""
    func viewControllerFrom(viewController: String) {
        viewControllerNameFrom = viewController
    }

    // 使われてなさそう。デバッグ用？
    // すべての記事を削除
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("There was an error")
        }
    }

    // cellを削除する
    func deleteCell(at indexPath: IndexPath) {
        contentManager.deleteContent(contentId: contentList[indexPath.row].id)
    }

    // 言語変更
    func changeViewLanguage() {
        // なんもないときのやつ
        text.text = NSLocalizedString("List is empty", comment: "")
        text2.text = NSLocalizedString(
            "Adding articles is easy. Tap below to get started.", comment: "")
        button.setTitle(NSLocalizedString("Learn how to save", comment: ""), for: UIControl.State())
        button.sizeToFit()
        button.layer.cornerRadius = 10.0

        // フッターのボタン
        if tableView.isEditing {
            bottomToolbarRightItem.title = NSLocalizedString("Done", comment: "")
            bottomToolbarLeftItem.title = NSLocalizedString("Delete", comment: "")
        } else {
            bottomToolbarRightItem.title = NSLocalizedString("Edit", comment: "")
        }
    }

    // MARK: Subscripts
}

// MARK: Extensions
extension ViewController: ContentListManagerDelegate, ContentManagerDelegate {
    func didUpdateContentList(
        _ contentListManager: ContentListManager, contentListResponse: ContentListResponse
    ) {
        DispatchQueue.main.async {
            // TODO: 一番下までスクロールしたら追加でコンテンツを取得できるようにする
            self.contentList = contentListResponse.data.content
            self.renderContentList()
            self.stopIndicator()
        }
    }

    func didUpdateContent(
        _ contentManager: ContentManager, contentResponse: ContentResponse
    ) {
        contentListManager.fetchContentList()
    }

    func didDeleteContent(_ contentManager: ContentManager) {
        contentListManager.fetchContentList()
    }

    func didFailWithError(error: Error) {
        print("Error", error)
    }
}

extension ViewController {
    func getDeviceInfo() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let code: String = String(cString: machine)

        let deviceCodeDic: [String: String] = [
            /* Simulator */
            "i386": "Simulator",
            "x86_64": "Simulator",
            /* iPod */
            "iPod1,1": "iPod Touch 1st",  // iPod Touch 1st Generation
            "iPod2,1": "iPod Touch 2nd",  // iPod Touch 2nd Generation
            "iPod3,1": "iPod Touch 3rd",  // iPod Touch 3rd Generation
            "iPod4,1": "iPod Touch 4th",  // iPod Touch 4th Generation
            "iPod5,1": "iPod Touch 5th",  // iPod Touch 5th Generation
            "iPod7,1": "iPod Touch 6th",  // iPod Touch 6th Generation
            /* iPhone */
            "iPhone1,1": "iPhone 2G",  // iPhone 2G
            "iPhone1,2": "iPhone 3G",  // iPhone 3G
            "iPhone2,1": "iPhone 3GS",  // iPhone 3GS
            "iPhone3,1": "iPhone 4",  // iPhone 4 GSM
            "iPhone3,2": "iPhone 4",  // iPhone 4 GSM 2012
            "iPhone3,3": "iPhone 4",  // iPhone 4 CDMA For Verizon,Sprint
            "iPhone4,1": "iPhone 4S",  // iPhone 4S
            "iPhone5,1": "iPhone 5",  // iPhone 5 GSM
            "iPhone5,2": "iPhone 5",  // iPhone 5 Global
            "iPhone5,3": "iPhone 5c",  // iPhone 5c GSM
            "iPhone5,4": "iPhone 5c",  // iPhone 5c Global
            "iPhone6,1": "iPhone 5s",  // iPhone 5s GSM
            "iPhone6,2": "iPhone 5s",  // iPhone 5s Global
            "iPhone7,1": "iPhone 6 Plus",  // iPhone 6 Plus
            "iPhone7,2": "iPhone 6",  // iPhone 6
            "iPhone8,1": "iPhone 6S",  // iPhone 6S
            "iPhone8,2": "iPhone 6S Plus",  // iPhone 6S Plus
            "iPhone8,4": "iPhone SE",  // iPhone SE
            "iPhone9,1": "iPhone 7",  // iPhone 7 A1660,A1779,A1780
            "iPhone9,3": "iPhone 7",  // iPhone 7 A1778
            "iPhone9,2": "iPhone 7 Plus",  // iPhone 7 Plus A1661,A1785,A1786
            "iPhone9,4": "iPhone 7 Plus",  // iPhone 7 Plus A1784
            "iPhone10,1": "iPhone 8",  // iPhone 8 A1863,A1906,A1907
            "iPhone10,4": "iPhone 8",  // iPhone 8 A1905
            "iPhone10,2": "iPhone 8 Plus",  // iPhone 8 Plus A1864,A1898,A1899
            "iPhone10,5": "iPhone 8 Plus",  // iPhone 8 Plus A1897
            "iPhone10,3": "iPhone X",  // iPhone X A1865,A1902
            "iPhone10,6": "iPhone X",  // iPhone X A1901
            "iPhone11,8": "iPhone XR",  // iPhone XR A1984,A2105,A2106,A2108
            "iPhone11,2": "iPhone XS",  // iPhone XS A2097,A2098
            "iPhone11,4": "iPhone XS Max",  // iPhone XS Max A1921,A2103
            "iPhone11,6": "iPhone XS Max",  // iPhone XS Max A2104

            /* iPad */
            "iPad1,1": "iPad 1 ",  // iPad 1
            "iPad2,1": "iPad 2 WiFi",  // iPad 2
            "iPad2,2": "iPad 2 Cell",  // iPad 2 GSM
            "iPad2,3": "iPad 2 Cell",  // iPad 2 CDMA (Cellular)
            "iPad2,4": "iPad 2 WiFi",  // iPad 2 Mid2012
            "iPad2,5": "iPad Mini WiFi",  // iPad Mini WiFi
            "iPad2,6": "iPad Mini Cell",  // iPad Mini GSM (Cellular)
            "iPad2,7": "iPad Mini Cell",  // iPad Mini Global (Cellular)
            "iPad3,1": "iPad 3 WiFi",  // iPad 3 WiFi
            "iPad3,2": "iPad 3 Cell",  // iPad 3 CDMA (Cellular)
            "iPad3,3": "iPad 3 Cell",  // iPad 3 GSM (Cellular)
            "iPad3,4": "iPad 4 WiFi",  // iPad 4 WiFi
            "iPad3,5": "iPad 4 Cell",  // iPad 4 GSM (Cellular)
            "iPad3,6": "iPad 4 Cell",  // iPad 4 Global (Cellular)
            "iPad4,1": "iPad Air WiFi",  // iPad Air WiFi
            "iPad4,2": "iPad Air Cell",  // iPad Air Cellular
            "iPad4,3": "iPad Air China",  // iPad Air ChinaModel
            "iPad4,4": "iPad Mini 2 WiFi",  // iPad mini 2 WiFi
            "iPad4,5": "iPad Mini 2 Cell",  // iPad mini 2 Cellular
            "iPad4,6": "iPad Mini 2 China",  // iPad mini 2 ChinaModel
            "iPad4,7": "iPad Mini 3 WiFi",  // iPad mini 3 WiFi
            "iPad4,8": "iPad Mini 3 Cell",  // iPad mini 3 Cellular
            "iPad4,9": "iPad Mini 3 China",  // iPad mini 3 ChinaModel
            "iPad5,1": "iPad Mini 4 WiFi",  // iPad Mini 4 WiFi
            "iPad5,2": "iPad Mini 4 Cell",  // iPad Mini 4 Cellular
            "iPad5,3": "iPad Air 2 WiFi",  // iPad Air 2 WiFi
            "iPad5,4": "iPad Air 2 Cell",  // iPad Air 2 Cellular
            "iPad6,3": "iPad Pro 9.7inch WiFi",  // iPad Pro 9.7inch WiFi
            "iPad6,4": "iPad Pro 9.7inch Cell",  // iPad Pro 9.7inch Cellular
            "iPad6,7": "iPad Pro 12.9inch WiFi",  // iPad Pro 12.9inch WiFi
            "iPad6,8": "iPad Pro 12.9inch Cell",  // iPad Pro 12.9inch Cellular
            "iPad6,11": "iPad 5th",  // iPad 5th Generation WiFi
            "iPad6,12": "iPad 5th",  // iPad 5th Generation Cellular
            "iPad7,1": "iPad Pro 12.9inch 2nd",  // iPad Pro 12.9inch 2nd Generation WiFi
            "iPad7,2": "iPad Pro 12.9inch 2nd",  // iPad Pro 12.9inch 2nd Generation Cellular
            "iPad7,3": "iPad Pro 10.5inch",  // iPad Pro 10.5inch A1701 WiFi
            "iPad7,4": "iPad Pro 10.5inch",  // iPad Pro 10.5inch A1709 Cellular
            "iPad7,5": "iPad 6th",  // iPad 6th Generation WiFi
            "iPad7,6": "iPad 6th",  // iPad 6th Generation Cellular
            "iPad8,1": "iPad Pro 11inch WiFi",  // iPad Pro 11inch WiFi
            "iPad8,2": "iPad Pro 11inch WiFi",  // iPad Pro 11inch WiFi
            "iPad8,3": "iPad Pro 11inch Cell",  // iPad Pro 11inch Cellular
            "iPad8,4": "iPad Pro 11inch Cell",  // iPad Pro 11inch Cellular
            "iPad8,5": "iPad Pro 12.9inch WiFi",  // iPad Pro 12.9inch WiFi
            "iPad8,6": "iPad Pro 12.9inch WiFi",  // iPad Pro 12.9inch WiFi
            "iPad8,7": "iPad Pro 12.9inch Cell",  // iPad Pro 12.9inch Cellular
            "iPad8,8": "iPad Pro 12.9inch Cell",  // iPad Pro 12.9inch Cellular
            "iPad11,1": "iPad Mini 5th WiFi",  // iPad mini 5th WiFi
            "iPad11,2": "iPad Mini 5th Cell",  // iPad mini 5th Cellular
            "iPad11,3": "iPad Air 3rd WiFi",  // iPad Air 3rd generation WiFi
            "iPad11,4": "iPad Air 3rd Cell",  // iPad Air 3rd generation Cellular
        ]

        if let deviceName = deviceCodeDic[code] {
            return deviceName
        } else {
            if code.range(of: "iPod") != nil {
                return "iPod Touch"
            } else if code.range(of: "iPad") != nil {
                return "iPad"
            } else if code.range(of: "iPhone") != nil {
                return "iPhone"
            } else {
                return "unknownDevice"
            }
        }
    }
}
