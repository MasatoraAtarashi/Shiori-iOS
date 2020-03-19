//
//  SettingViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2020/03/19.
//  Copyright © 2020 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit

protocol SettingDelegate {
    func viewControllerFrom(viewController: String)
}

class SettingViewController: UIViewController {
    var delegate : SettingDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        let viewControllerName = "SettingViewController"
        
        delegate?.viewControllerFrom(viewController: viewControllerName)
    }
}
