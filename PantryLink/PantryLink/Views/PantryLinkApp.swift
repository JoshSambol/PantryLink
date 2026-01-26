//
//  PantryLinkApp.swift
//  PantryLink
//
//  Created by Joshua Sambol on 5/27/25.
//

import SwiftUI

@main
struct PantryLinkApp: App {
    // Connect the AppDelegate for push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate)

            //StockView()
            //HomeView()
            //NavView()
        }
    }
}
