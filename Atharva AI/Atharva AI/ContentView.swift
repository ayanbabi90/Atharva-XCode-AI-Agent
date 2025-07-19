//
//  ContentView.swift
//  Atharva AI
//
//  Created by ayan Chakraborty on 19/07/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ChatView()
                .navigationTitle("Atharva AI")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }
}

#Preview {
    ContentView()
}
