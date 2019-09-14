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

class ShareViewController: SLComposeServiceViewController {
    
    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // titleName
        self.title = "テスト"
        
        // color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:1.0, green:0.75, blue:0.5, alpha:1.0)
        
        // postName
        let controller: UIViewController = self.navigationController!.viewControllers.first!
        controller.navigationItem.rightBarButtonItem!.title = "保存"
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
////        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//        let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
//        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
//
//        let puclicURL = String(kUTTypeURL)  // "public.url"
//
//        // shareExtension で NSURL を取得
//        if itemProvider.hasItemConformingToTypeIdentifier(puclicURL) {
//            itemProvider.loadItem(forTypeIdentifier: puclicURL, options: nil, completionHandler: { (item, error) in
//                // NSURLを取得する
//                if let url: NSURL = item as? NSURL {
//                    // ----------
//                    // 保存処理
//                    // ----------
//                    let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//                    sharedDefaults.set("unko", forKey: self.keyName)  // そのページのURL保存
//                    sharedDefaults.synchronize()
//                    print(sharedDefaults.object(forKey: self.keyName) as? String)
//                }
//                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//            })
//        }

        
//            let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
//            let itemProvider = extensionItem.attachments?.first as! NSItemProvider
//
//                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
//                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
//                        if let resultDict = result as? NSDictionary {
//                            let a = resultDict[NSExtensionJavaScriptPreprocessingResultsKey] as AnyObject
//                            let unko = a["url"]
//                            let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//                            sharedDefaults.set(unko, forKey: self.keyName)  // そのページのURL保存
//                            sharedDefaults.synchronize()
//                        } else {
//                            let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
//                            sharedDefaults.set("anal", forKey: self.keyName)  // そのページのURL保存
//                            sharedDefaults.synchronize()
//                        }
//                        } as! NSItemProvider.CompletionHandler)
//                }
        
        for item: Any in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            
            if let attachments = inputItem.attachments as? [NSItemProvider] {
                for itemProvider : NSItemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier("public.data") {
                        itemProvider.loadItem(forTypeIdentifier: "public.data", options: nil, completionHandler: {
                            (item, error) in
                            
                            if let dictionary = item as? NSDictionary {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
//                                    println(results["url"]);
//                                    println(results["title"]);
                                    let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
                                    if let result = results["url"] {
                                        let resultsDic = ["url": results["url"], "title": results["title"], "positionX": results["positionX"], "positionY": results["positionY"], "time": results["time"]]
                                        sharedDefaults.set(resultsDic, forKey: self.keyName)  // そのページのURL保存
                                        sharedDefaults.synchronize()
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
