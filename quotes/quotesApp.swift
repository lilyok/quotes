//
//  quotesApp.swift
//  quotes
//
//  Created by Liliia Ivanova on 20.05.2021.
//

import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    let notifications = Notifications()
    var serverClient: ServerClient? = nil
    static var originalAppDelegate: AppDelegate!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notifications.requestAuthorisation()
        AppDelegate.originalAppDelegate = self

        return true
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed registration: \(error.localizedDescription)")
        
        // FOR SIMULATOR
        if error.localizedDescription == "remote notifications are not supported in the simulator" {
            let token = ""  //  TODO for testing on simulator hardcode, deleted for public commit
            self.serverClient = ServerClient(userID: "", deviceToken: token, completionHandler: { _, _ in }, completionErrorHandler:  { _ in }, completionInitHandler:  {})
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let parts = deviceToken.map { data in
            return String(format: "%02.2hhx", data)
        }

        let token = parts.joined()
        self.serverClient = ServerClient(userID: "", deviceToken: token, completionHandler: { _, _ in }, completionErrorHandler:  { _ in }, completionInitHandler:  {})
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }
}


@main
struct quotesApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                UIApplication.shared.applicationIconBadgeNumber = 0
            case .inactive:
                break
//                print("scene is now inactive!")
            case .background:
                break
//                print("scene is now in the background!")
            @unknown default:
                break
//                print("Apple must have added something new!")
            }
        }
    }
}
