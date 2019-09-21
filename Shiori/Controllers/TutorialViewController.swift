//
//  TutorialViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/18.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit

protocol TutorialDelegate {
    func viewControllerFrom(viewController: String)
}

class TutorialViewController: UIViewController {
    var delegate : TutorialDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        let viewControllerName = "TutorialViewController"
        
        delegate?.viewControllerFrom(viewController: viewControllerName)
    }
}
