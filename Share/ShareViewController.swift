//
//  ShareViewController.swift
//  Share
//
//  Created by あたらしまさとら on 2019/09/13.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import CoreData
import MobileCoreServices
import Social
import UIKit

class ShareViewController: SLComposeServiceViewController {

    var contentManager = ContentManager()

    let suiteName: String = "group.com.masatoraatarashi.Shiori"
    let keyName: String = "shareData"

    override func viewDidLoad() {
        super.viewDidLoad()

        contentManager.delegate = self

        self.title = "Shiori"
        // postName
        let controller: UIViewController = self.navigationController!.viewControllers.first!
        controller.navigationItem.rightBarButtonItem!.title = NSLocalizedString("Save", comment: "")
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    // TODO: リファクタリング
    override func didSelectPost() {
        for item: Any in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem

            if let attachments = inputItem.attachments {
                for itemProvider: NSItemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier("public.data") {
                        itemProvider.loadItem(
                            forTypeIdentifier: "public.data", options: nil,
                            completionHandler: {
                                (item, _) in

                                if let dictionary = item as? NSDictionary {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        let results =
                                            dictionary[NSExtensionJavaScriptPreprocessingResultsKey]
                                            as! NSDictionary

                                        var device = "iPhone"
                                        if self.isIPad() {
                                         device = "iPad"
                                        }
                                        
                                        // 会員登録しているときの処理
                                        if Const().isLoggedInUser() {
                                            if results["url"] != nil {
                                                let title = results["title"] as? String
                                                let url = results["url"] as? String
                                                let userAgent = results["userAgent"] as? String
                                                let thumbnailImgUrl = results["image"] as? String
                                                let scrollPositionXString =
                                                    results["scrollPositionX"] as? Int
                                                let scrollPositionYString =
                                                    results["scrollPositionY"] as? Int
                                                let maxScrollPositionXString =
                                                    results["maxScrollPositionX"] as? Int
                                                let maxScrollPositionYString =
                                                    results["maxScrollPositionY"] as? Int
                                                let videoPlaybackPositionString =
                                                    results["time"] as! String
                                                let audioPlaybackPosition = Int(results["audioPlaybackPosition"] as? Double ?? 0)
                                                let scrollPositionX = Int(
                                                    scrollPositionXString ?? 0)
                                                let scrollPositionY = Int(
                                                    scrollPositionYString ?? 0)
                                                let maxScrollPositionX = Int(
                                                    maxScrollPositionXString ?? 0)
                                                let maxScrollPositionY = Int(
                                                    maxScrollPositionYString ?? 0)
                                                let videoPlaybackPosition = Int(
                                                    videoPlaybackPositionString)
                                                let contentRequest = ContentRequest(
                                                    title: title ?? "",
                                                    url: url ?? "",
                                                    userAgent: userAgent ?? "",
                                                    device: device,
                                                    browser: "Safari",
                                                    thumbnailImgUrl: thumbnailImgUrl ?? "",
                                                    scrollPositionX: scrollPositionX,
                                                    scrollPositionY: scrollPositionY,
                                                    maxScrollPositionX: maxScrollPositionX,
                                                    maxScrollPositionY: maxScrollPositionY,
                                                    videoPlaybackPosition: videoPlaybackPosition ?? 0,
                                                    audioPlaybackPosition: audioPlaybackPosition ,
                                                    specifiedText: nil, specifiedDomId: nil,
                                                    specifiedDomClass: nil, specifiedDomTag: nil)

                                                self.contentManager.postContent(
                                                    content: contentRequest)

                                                self.extensionContext?.completeRequest(
                                                    returningItems: nil, completionHandler: nil)
                                            } else {
                                                self.extensionContext?.completeRequest(
                                                    returningItems: nil, completionHandler: nil)
                                            }
                                        } else {  // 会員登録せずに使用している時の処理
                                            let sharedDefaults: UserDefaults = UserDefaults(
                                                suiteName: self.suiteName)!
                                            var storedArray: [[String: String]] =
                                                sharedDefaults.array(forKey: self.keyName)
                                                as? [[String: String]] ?? []

                                            let scrollPositionX: Int =
                                                results["scrollPositionX"] as? Int ?? 0
                                            let scrollPositionY: Int =
                                                results["scrollPositionY"] as? Int ?? 0
                                            let maxScrollPositionX: Int =
                                                results["maxScrollPositionX"] as? Int ?? 0
                                            let maxScrollPositionY: Int =
                                                results["maxScrollPositionY"] as? Int ?? 0

                                            let scrollPositionXString: String = String(
                                                describing: scrollPositionX)
                                            let scrollPositionYString: String = String(
                                                describing: scrollPositionY)
                                            let maxScrollPositionXString: String = String(
                                                describing: maxScrollPositionX)
                                            let maxScrollPositionYString: String = String(
                                                describing: maxScrollPositionY)

                                            if results["url"] != nil {
                                                let resultsDic = [
                                                    "url": results["url"],
                                                    "title": results["title"],
                                                    "positionX": scrollPositionXString,
                                                    "positionY": scrollPositionYString,
                                                    "maxScrollPositionX": maxScrollPositionXString,
                                                    "maxScrollPositionY": maxScrollPositionYString,
                                                    "image": results["image"],
                                                    "date": results["date"],
                                                    "videoPlaybackPosition":
                                                        results["time"],
                                                ]

                                                storedArray.append(
                                                    resultsDic as! [String: String])
                                                sharedDefaults.set(
                                                    storedArray, forKey: self.keyName)

                                                self.extensionContext?.completeRequest(
                                                    returningItems: nil, completionHandler: nil)
                                            } else {
                                                self.extensionContext?.completeRequest(
                                                    returningItems: nil, completionHandler: nil)
                                            }
                                        }
                                    })
                                } else {
                                    self.extensionContext?.completeRequest(
                                        returningItems: nil, completionHandler: nil)
                                }

                            })
                    } else {
                        self.extensionContext?.completeRequest(
                            returningItems: nil, completionHandler: nil)
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

extension ShareViewController: ContentManagerDelegate {
    func didCreateContent(_ contentManager: ContentManager) {
        print("content created")
    }

    func didFailWithError(error: Error) {
        print("Error", error)
    }

}
