//
//  habitapp6App.swift
//  habitapp6
//
//  Created by Raúl Martínez Gutiérrez on 3/1/26.
//

import SwiftUI

@main
struct habitapp6App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
