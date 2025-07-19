//
//  Atharva_AIApp.swift
//  Atharva AI
//
//  Created by ayan Chakraborty on 19/07/25.
//

import SwiftUI
import AtharvaCore

@main
struct Atharva_AIApp: App {
    init() {
        print("[DEBUG] App: Initializing Atharva AI App...")
        AtharvaFramework.initialize()
        print("[DEBUG] App: App initialization complete")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
