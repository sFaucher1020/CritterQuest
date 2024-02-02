//
//  CritterQuestApp.swift
//  CritterQuest
//
//  Created by Samuel Faucher on 1/31/24.
//

import SwiftUI

@main
struct CritterQuestApp: App {
    @StateObject var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
