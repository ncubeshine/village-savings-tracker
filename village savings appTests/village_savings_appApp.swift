//
//  village_savings_appApp.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

@main
struct village_savings_appApp: App {
    @StateObject private var appData = AppData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
    }
}
