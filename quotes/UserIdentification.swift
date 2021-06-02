//
//  UserIdentification.swift
//  quotes
//
//  Created by Liliia Ivanova on 30.05.2021.
//

import Foundation
import CloudKit


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
        let instruction = "Check iCloud Settings:\nSettings > \(userName) > iCloud.\n\nTurn iCloud features on or off for \(appName)."
        
        container.fetchUserRecordID(completionHandler: { (record, error) in
            if let error = error {
                result = error.localizedDescription + "\n\n\(instruction)"
                isErrorOccurred = true
                completionHandler(result, isErrorOccurred)
            } else {
                container.discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                    if let currentuserID = userID?.userRecordID {
                        result = currentuserID.recordName
                        isErrorOccurred = false
                    }
                    else if let error = error {
                        result = error.localizedDescription
                        isErrorOccurred = true
                    }
                    completionHandler(result, isErrorOccurred)
                })
            }
        })
    }
}
