//
//  SelectFolderTableViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/05/05.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import UIKit

class SelectFolderTableViewController: UITableViewController {

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    // TODO: 削除
    var selectedIndexPath: Int = 0
    var articles: [Article] = []

    var content: Content?
    var folderList: [Folder] = []

    var folderListManager = FolderListManager()
    var folderManager = FolderManager()

    // MARK: IBOutlets
    @IBOutlet weak var navTitle: UINavigationItem!

    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        folderListManager.delegate = self
        folderManager.delegate = self

        initIndicator()
        const.activityIndicatorView.startAnimating()
        folderListManager.fetchFolderList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navTitle.title = NSLocalizedString("Add to folder", comment: "")
    }

    // MARK: IBActions
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addFolder(_ sender: Any) {
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

    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        //        let cell = tableView.dequeueReusableCell(
        //            withIdentifier: "cellForFolderSelection", for: indexPath)
        //
        //        // Configure the cell...
        //        let categories = UserDefaults.standard.array(forKey: "categories")?.dropFirst(2)
        //        cell.textLabel!.text = categories![indexPath.row + 2] as? String
        //
        //        if let folderName = categories?[indexPath.row + 2] {
        //            if articles[selectedIndexPath].folderInt?.contains(folderName as! String) ?? false {
        //                cell.textLabel!.text! += NSLocalizedString("(Added)", comment: "")
        //            }
        //        }
        //        return cell

        // TODO: すでにフォルダに追加されていたらその旨を表示する
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cellForFolderSelection", for: indexPath)
        cell.textLabel?.text = folderList[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preNC = self.navigationController?.presentingViewController as! UINavigationController
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController
        let categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        preVC.addArticleToFolder(self.selectedIndexPath, categories[indexPath.row + 2])
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Other Methods
    func renderFolderList() {
        tableView.reloadData()
    }

    // インジケータ
    func initIndicator() {
        tableView.addSubview(const.activityIndicatorView)
        tableView.bringSubviewToFront(const.activityIndicatorView)
        const.activityIndicatorView.center = CGPoint(x: tableView.center.x, y: 50)
    }
    // MARK: Subscripts
}

// MARK: Extensions
extension SelectFolderTableViewController: FolderListManagerDelegate, FolderManagerDelegate {
    func didCreateFolder(_ folderManager: FolderManager, folderResponse: FolderResponse) {
        DispatchQueue.main.async {
            self.folderListManager.fetchFolderList()
        }
    }

    func didUpdateFolder(_ folderManager: FolderManager, folderResponse: FolderResponse) {
        return
    }

    func didDeleteFolder(_ folderManager: FolderManager) {
        return
    }

    func didUpdateFolderList(
        _ folderListManager: FolderListManager, folderListResponse: FolderListResponse
    ) {
        DispatchQueue.main.async {
            self.folderList = Array(folderListResponse.data.folder[2...])
            self.renderFolderList()
            const.activityIndicatorView.stopAnimating()
        }
    }

    func didFailWithError(error: Error) {
        print("Error", error)
    }

}
