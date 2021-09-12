//
//  OmniAuthWebViewController.swift
//  Shiori
//
//  Created by あたらしまさとら on 2021/09/13.
//  Copyright © 2021 Masatora Atarashi. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class OmniAuthWebViewController: UIViewController {

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
    }
}
