//
//  ShareViewController.swift
//  Share
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

class ShareViewController: SLComposeServiceViewController {
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Shiori"
        // postName
        let controller: UIViewController = self.navigationController!.viewControllers.first!
        controller.navigationItem.rightBarButtonItem!.title = NSLocalizedString("Save", comment: "")
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {

        
        for item: Any in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            
            if let attachments = inputItem.attachments {
                for itemProvider : NSItemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier("public.data") {
                        itemProvider.loadItem(forTypeIdentifier: "public.data", options: nil, completionHandler: {
                            (item, error) in
                            
                            
                            if let dictionary = item as? NSDictionary {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                                    
                                    let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
                                    var storedArray: [Dictionary<String, String>] = sharedDefaults.array(forKey: self.keyName) as? [Dictionary<String, String>] ?? []
                                    
                                    if results["url"] != nil {
                                        let resultsDic = ["url": results["url"], "title": results["title"], "positionX": results["positionX"], "positionY": results["positionY"], "time": results["time"], "image": results["image"], "date": results["date"], "haveRead": "true"]
                                        
                                        storedArray.append(resultsDic as! [String : String])
                                        sharedDefaults.set(storedArray, forKey: self.keyName)
                                        
                                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                                    } else {
                                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                                    }
                                })
                            } else {
                                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                            }
                            
                        })
                    } else {
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                }
                
            }
        }

    }
    
    

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
