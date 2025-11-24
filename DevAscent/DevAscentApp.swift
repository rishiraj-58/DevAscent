//
//  DevAscentApp.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI
import SwiftData

@main
struct DevAscentApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: PlanTask.self)
    }
}
