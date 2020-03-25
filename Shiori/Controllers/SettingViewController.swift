//
//  SettingViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/03/25.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // ③テーブルの行数を指定するメソッド（必須）
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
    
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // セルを取得する
           let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "advertisementCell", for: indexPath)
           // セルに値を設定する
           return cell
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
