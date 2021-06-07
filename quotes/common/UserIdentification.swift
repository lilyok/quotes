//
//  UserIdentification.swift
//  quotes
//
//  Created by Liliia Ivanova on 30.05.2021.
//

import Foundation
import CloudKit
import UIKit

func getIdentifierForVendor(appName: String) -> (String, Bool) {  // if user forbide using iCloud
    let vendor = UIDevice.current.identifierForVendor
    if vendor == nil {
        return ("Please restart \(appName)", true)
    }
    return (vendor!.uuidString, false)
}

func getUserRecordID(completionHandler: @escaping (_ result: String, _ isErrorOccurred: Bool) -> ()) {
    let container = CKContainer(identifier: "iCloud.LilContainer")
    var result: String = ""
    var isErrorOccurred = false
    
    container.requestApplicationPermission(.userDiscoverability) { (status, error) in
        
        var userName = NSFullUserName()
        if userName == "" {
            userName = "[your name]"
        }
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "quotes"
        
        container.fetchUserRecordID(completionHandler: { (record, error) in
            if let _ = error {
                (result, isErrorOccurred) = getIdentifierForVendor(appName: appName)
                completionHandler(result, isErrorOccurred)
            } else {
                container.discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                    if let currentuserID = userID?.userRecordID {
                        result = currentuserID.recordName
                        isErrorOccurred = false
                    }
                    else if let _ = error {
                        (result, isErrorOccurred) = getIdentifierForVendor(appName: appName)
                    }
                    completionHandler(result, isErrorOccurred)
                })
            }
        })
    }
}
