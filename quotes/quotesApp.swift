//
//  quotesApp.swift
//  quotes
//
//  Created by Liliia Ivanova on 20.05.2021.
//

import SwiftUI

@main
struct quotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
