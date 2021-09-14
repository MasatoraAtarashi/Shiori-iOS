//
//  InitialViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/12.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.opaqueSeparator.cgColor
        signUpButton.layer.cornerRadius = 5
    }
}

extension InitialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        self.pageControll.currentPage = index
    }
}
