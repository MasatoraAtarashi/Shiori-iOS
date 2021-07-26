//
//  SupportedServicesViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/05/03.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import UIKit

class SupportedServicesViewController: UITableViewController {

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    let services = [
        "Youtube", "nicovideo(ニコニコ動画)", "Ted.com", "Dailymotion", "pornhub", "redtube", "tube8",
        "spankbang",
    ]
    let sectionTitles = [NSLocalizedString("Supported video sites", comment: "")]

    // MARK: IBOutlets
    // MARK: Initializers
    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: IBActions
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    // 追加④ セルに値を設定するデータソースメソッド（必須）
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = services[indexPath.row]
        return cell
    }

    // MARK: Other Methods
    // MARK: Subscripts
}

// MARK: Extensions
