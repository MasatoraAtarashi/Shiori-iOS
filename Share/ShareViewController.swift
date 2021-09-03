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

                                        let sharedDefaults: UserDefaults = UserDefaults(
                                            suiteName: self.suiteName)!
                                        var storedArray: [[String: String]] =
                                            sharedDefaults.array(forKey: self.keyName)
                                            as? [[String: String]] ?? []

                                        if results["url"] != nil {
                                            //                                            let resultsDic = [
                                            //                                                "url": results["url"], "title": results["title"],
                                            //                                                "positionX": results["positionX"],
                                            //                                                "positionY": results["positionY"],
                                            //                                                "time": results["time"], "image": results["image"],
                                            //                                                "date": results["date"],
                                            //                                                "videoPlaybackPosition": results[
                                            //                                                    "videoPlaybackPosition"],
                                            //                                            ]
                                            //
                                            //                                            storedArray.append(resultsDic as! [String: String])
                                            //                                            sharedDefaults.set(storedArray, forKey: self.keyName)
                                            let title = results["title"] as! String
                                            let url = results["url"] as! String
                                            let thumbnailImgUrl = results["image"] as! String
                                            let scrollPositionXString =
                                                results["positionX"] as! String
                                            let scrollPositionYString =
                                                results["positionY"] as! String
                                            let maxScrollPositionXString =
                                                results["maxScrollPositionX"] as! String
                                            let maxScrollPositionYString =
                                                results["maxScrollPositionY"] as! String
                                            let videoPlaybackPositionString =
                                                results["time"] as! String
                                            let scrollPositionX = Int(scrollPositionXString)
                                            let scrollPositionY = Int(scrollPositionYString)
                                            let maxScrollPositionX = Int(maxScrollPositionXString)
                                            let maxScrollPositionY = Int(maxScrollPositionYString)
                                            let videoPlaybackPosition = Int(
                                                videoPlaybackPositionString)
                                            let contentRequest = ContentRequest(
                                                title: title, url: url,
                                                thumbnailImgUrl: thumbnailImgUrl,
                                                scrollPositionX: scrollPositionX ?? 0,
                                                scrollPositionY: scrollPositionY ?? 0,
                                                maxScrollPositionX: maxScrollPositionX ?? 0,
                                                maxScrollPositionY: maxScrollPositionY ?? 0,
                                                videoPlaybackPosition: videoPlaybackPosition ?? 0,
                                                specifiedText: nil, specifiedDomId: nil,
                                                specifiedDomClass: nil, specifiedDomTag: nil)

                                            self.contentManager.postContent(content: contentRequest)

                                            self.extensionContext?.completeRequest(
                                                returningItems: nil, completionHandler: nil)
                                        } else {
                                            self.extensionContext?.completeRequest(
                                                returningItems: nil, completionHandler: nil)
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
