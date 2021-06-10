//
//  Notifications.swift
//  quotes
//
//  Created by Liliia Ivanova on 09.06.2021.
//

import SwiftUI
import UserNotifications


let center = UNUserNotificationCenter.current()

class Notifications {
    func requestAuthorisation() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                return
            }
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    
}
