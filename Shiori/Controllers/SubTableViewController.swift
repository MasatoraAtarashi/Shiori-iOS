//
//  SubTableViewController.swift
//
//
//  Created by あたらしまさとら on 2020/05/05.
//

import NVActivityIndicatorView
import SwipeCellKit
import UIKit

class SubTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    var folderListManager = FolderListManager()
    var folderManager = FolderManager()

    var folderList: [Folder] = []
    let folderViewActivityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 20, height: 20),
        type: NVActivityIndicatorType.ballSpinFadeLoader,
        color: UIColor.lightGray,
        padding: 0
    )

    var r: Int = UserDefaults.standard.integer(forKey: "r")
    var b: Int = UserDefaults.standard.integer(forKey: "r")
    var g: Int = UserDefaults.standard.integer(forKey: "r")

    // MARK: IBOutlets
    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        folderListManager.delegate = self
        folderManager.delegate = self

        initIndicator()

        folderViewActivityIndicatorView.startAnimating()
        folderListManager.fetchFolderList()
    }

    override func viewWillAppear(_ animated: Bool) {
        changeBackgroundColor()

    }

    // MARK: IBActions
    // MARK: SwipeTableViewCellDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return UserDefaults.standard.array(forKey: "categories")?.count ?? 2
        return folderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let bgColor: UIColor = UIColor(
            red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        //                if indexPath.row == 0 || indexPath.row == 1 {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellForSub", for: indexPath)
        //                    // Configure the cell...
        //                    cell.textLabel!.text =
        //                        UserDefaults.standard.array(forKey: "categories")![indexPath.row] as? String
        //
        //                    cell.backgroundColor = bgColor
        //                    if r == 0 || r == 60 {
        //                        cell.textLabel?.textColor = UIColor.white
        //                    } else {
        //                        cell.textLabel?.textColor = UIColor.black
        //                    }
        //
        //                    return cell
        //                } else {
        //                    let cell =
        //                        tableView.dequeueReusableCell(withIdentifier: "cellForSub", for: indexPath)
        //                        as! SwipeTableViewCell
        //                    cell.delegate = self
        //                    cell.textLabel!.text =
        //                        UserDefaults.standard.array(forKey: "categories")![indexPath.row] as? String
        //
        //                    cell.backgroundColor = bgColor
        //                    if r == 0 || r == 60 {
        //                        cell.textLabel?.textColor = UIColor.white
        //                    } else {
        //                        cell.textLabel?.textColor = UIColor.black
        //                    }
        //
        //                    return cell
        //                }
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cellForSub", for: indexPath)
            as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = String(folderList[indexPath.row].name)
        cell.backgroundColor = bgColor
        if r == 0 || r == 60 {
            cell.textLabel?.textColor = UIColor.white
        } else {
            cell.textLabel?.textColor = UIColor.black
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let preNC = self.navigationController?.presentingViewController as! UINavigationController
        //        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController
        //        preVC.folderInt =
        //            UserDefaults.standard.array(forKey: "categories")?[indexPath.row] as! String
        //        self.dismiss(animated: true, completion: nil)
        let preNC = self.navigationController?.presentingViewController as! UINavigationController
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController
        preVC.folderId = folderList[indexPath.row].folderId
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(
        _ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }

    // swipeしたときの処理
    func tableView(
        _ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(
            style: .destructive, title: NSLocalizedString("Delete", comment: "")
        ) { _, indexPath in
            self.deleteFolder(at: indexPath)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return [deleteAction]
    }

    // MARK: Other Methods
    // フォルダ一覧を表示
    func renderFolderList() {
        tableView.reloadData()
    }

    // 背景色を設定
    func changeBackgroundColor() {
        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        let bgColor: UIColor = UIColor(
            red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.view.backgroundColor = bgColor
        self.tableView.backgroundColor = bgColor
        //        footer color
        self.navigationController?.toolbar.barTintColor = bgColor
        //        header color
        self.navigationController?.navigationBar.barTintColor = bgColor
    }

    // インジケータ初期化
    func initIndicator() {
        tableView.addSubview(folderViewActivityIndicatorView)
        tableView.bringSubviewToFront(folderViewActivityIndicatorView)
        folderViewActivityIndicatorView.center = CGPoint(
            x: self.view.frame.maxX * 0.7 / 2, y: 20)
    }

    // フォルダ(カテゴリー)を削除する
    func deleteFolder(at indexPath: IndexPath) {
        var categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        if let i = categories.firstIndex(of: categories[indexPath.row]) {
            categories.remove(at: i)
        }
        UserDefaults.standard.set(categories, forKey: "categories")
        self.tableView.reloadData()
    }
    // フォルダを追加する
    @IBAction func addCategory(_ sender: Any) {
        var alertTextField: UITextField?

        let alert = UIAlertController(
            title: NSLocalizedString("Add Folder", comment: ""),
            message: NSLocalizedString("Use folders to organize your saved articles.", comment: ""),
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(
            configurationHandler: { (textField: UITextField!) in
                alertTextField = textField
                textField.placeholder = NSLocalizedString(
                    "Examples: recipes, politics ...", comment: "")
            })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default
            ) { _ in
                if let text = alertTextField?.text {
                    //                    var categories = UserDefaults.standard.array(forKey: "categories")
                    //                    categories?.append(text)
                    //                    UserDefaults.standard.set(categories, forKey: "categories")
                    //                    self.tableView.reloadData()
                    let folderRequest = FolderRequest(name: text)
                    self.folderManager.postFolder(folder: folderRequest)
                }
            }
        )

        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Subscripts
}

// MARK: Extensions
extension SubTableViewController: FolderListManagerDelegate, FolderManagerDelegate {
    func didCreateFolder(_ folderManager: FolderManager, folderResponse: FolderResponse) {
        folderViewActivityIndicatorView.startAnimating()
        folderListManager.fetchFolderList()
    }

    func didUpdateFolder(_ folderManager: FolderManager, folderResponse: FolderResponse) {
        // TODO: 実装
        print("didUpdateFolder")
    }

    func didDeleteFolder(_ folderManager: FolderManager) {
        // TODO: 実装
        print("didDeleteFolder")
    }

    func didUpdateFolderList(
        _ folderListManager: FolderListManager, folderListResponse: FolderListResponse
    ) {
        DispatchQueue.main.async {
            self.folderList = folderListResponse.data.folder
            self.renderFolderList()
            self.folderViewActivityIndicatorView.stopAnimating()
        }
    }

    func didFailWithError(error: Error) {
        print("Error", error)
    }
}
