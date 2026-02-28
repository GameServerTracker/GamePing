//
//  GameStatusApp.swift
//  GameStatus
//
//  Created by Tom on 10/05/2025.
//

import SwiftUI
import SwiftData

@main
struct GameStatusApp: App {
    @State private var statusManager = ServerStatusManager()

    var body: some Scene {
        WindowGroup {
            ServerListView()
                .environment(statusManager)
                .modelContainer(for: GameServer.self)
        }
    }
}
