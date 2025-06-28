//
//  FootballClubApp.swift
//  FootballClub
//
//  Created by Dawood Akbar on 28/06/2025.
//

import SwiftUI

@main
struct FootballClubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
