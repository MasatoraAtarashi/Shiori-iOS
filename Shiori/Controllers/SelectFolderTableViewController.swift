//
//  SelectFolderTableViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/05/05.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import UIKit

class SelectFolderTableViewController: UITableViewController {

    var selectedIndexPath: Int = 0
    var articles: [Article] = []

    @IBOutlet weak var navTitle: UINavigationItem!

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
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                textField.placeholder = NSLocalizedString("Examples: recipes, politics ...", comment: "")
            })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                if let text = alertTextField?.text {
                    var categories = UserDefaults.standard.array(forKey: "categories")
                    categories?.append(text)
                    UserDefaults.standard.set(categories, forKey: "categories")
                    self.tableView.reloadData()
                }
            }
        )

        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navTitle.title = NSLocalizedString("Add to folder", comment: "")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var count: Int
        if UserDefaults.standard.array(forKey: "categories")?.count ?? 0 > 2 {
            count = UserDefaults.standard.array(forKey: "categories")!.count - 2
        } else {
            count = 0
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellForFolderSelection", for: indexPath)

        // Configure the cell...
        var categories = UserDefaults.standard.array(forKey: "categories")?.dropFirst(2)
        cell.textLabel!.text = categories![indexPath.row + 2] as? String

        if let folderName = categories?[indexPath.row + 2] {
            if articles[selectedIndexPath].folderInt?.contains(folderName as! String) ?? false {
                cell.textLabel!.text! += NSLocalizedString("(Added)", comment: "")
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preNC = self.navigationController?.presentingViewController as! UINavigationController
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController
        var categories = UserDefaults.standard.array(forKey: "categories") as! [String]
        preVC.addArticleToFolder(self.selectedIndexPath, categories[indexPath.row + 2])
        self.dismiss(animated: true, completion: nil)
    }
}
