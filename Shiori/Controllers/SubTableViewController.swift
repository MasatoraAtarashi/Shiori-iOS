//
//  SubTableViewController.swift
//  
//
//  Created by あたらしまさとら on 2020/05/05.
//

import UIKit
import SwipeCellKit

class SubTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var r: Int = UserDefaults.standard.integer(forKey: "r")
    var b: Int = UserDefaults.standard.integer(forKey: "r")
    var g: Int = UserDefaults.standard.integer(forKey: "r")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        r = UserDefaults.standard.integer(forKey: "r")
        b = UserDefaults.standard.integer(forKey: "b")
        g = UserDefaults.standard.integer(forKey: "g")
        let bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.view.backgroundColor = bgColor
        self.tableView.backgroundColor = bgColor
    //        footer color
        self.navigationController?.toolbar.barTintColor = bgColor
    //        header color
        self.navigationController?.navigationBar.barTintColor = bgColor
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UserDefaults.standard.array(forKey: "categories")?.count ?? 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        if indexPath.row == 0 || indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellForSub", for: indexPath)
            // Configure the cell...
            cell.textLabel!.text = UserDefaults.standard.array(forKey: "categories")![indexPath.row] as? String
            
            cell.backgroundColor = bgColor
            if r == 0 || r == 60 {
                cell.textLabel?.textColor = UIColor.white
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellForSub", for: indexPath) as! SwipeTableViewCell
            cell.delegate = self
            // Configure the cell...
            cell.textLabel!.text = UserDefaults.standard.array(forKey: "categories")![indexPath.row] as? String
            
            cell.backgroundColor = bgColor
            if r == 0 || r == 60 {
                cell.textLabel?.textColor = UIColor.white
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//        print(self.navigationController)
//        print(self.navigationController?.presentingViewController)
        let preNC = self.navigationController?.presentingViewController as! UINavigationController
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! ViewController
        preVC.folderInt = UserDefaults.standard.array(forKey: "categories")?[indexPath.row] as! String
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }
    
    //swipeしたときの処理
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { action, indexPath in
            self.deleteFolder(at: indexPath)
        }
        // customize the action appearance
        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage(systemName: "trash.fill")
        } else {
            // Fallback on earlier versions
        }
        return [deleteAction]
    }
    
    //フォルダ(カテゴリー)を削除する
    func deleteFolder(at indexPath: IndexPath) {
        print(UserDefaults.standard.array(forKey: "categories")![indexPath.row] as? String)
        var categories = UserDefaults.standard.array(forKey: "categories") as! Array<String>
        if let i = categories.firstIndex(of: categories[indexPath.row]) {
            categories.remove(at: i)
        }
        UserDefaults.standard.set(categories, forKey:"categories")
        self.tableView.reloadData()
    }
    //フォルダを追加する
    @IBAction func addCategory(_ sender: Any) {
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
                    UserDefaults.standard.set(categories, forKey:"categories")
                    self.tableView.reloadData()
                }
            }
        )

        self.present(alert, animated: true, completion: nil)
    }
    
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
