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
    var delegate: TutorialDelegate?

    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        text1.text = NSLocalizedString("Tap the 'Share' button on Mobile Safari", comment: "")
        text2.text = NSLocalizedString("* If 'Shiori' is not displayed, turn on 'Shiori' from 'More'", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {

        let r = UserDefaults.standard.integer(forKey: "r")
        let b = UserDefaults.standard.integer(forKey: "b")
        let g = UserDefaults.standard.integer(forKey: "g")
        var bgColor: UIColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
        self.view.backgroundColor = bgColor
        if r == 0 || r == 60 {
            text1.textColor = UIColor.white
            text2.textColor = UIColor.white
        } else {
            text1.textColor = UIColor.black
            text2.textColor = UIColor.black
        }

    }

    override func viewWillDisappear(_ animated: Bool) {

        let viewControllerName = "TutorialViewController"
        delegate?.viewControllerFrom(viewController: viewControllerName)

    }
}
