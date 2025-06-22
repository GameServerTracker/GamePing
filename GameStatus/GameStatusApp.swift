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
    var body: some Scene {
        WindowGroup {
            ServerListView()
                .modelContainer(for: GameServer.self)
        }
    }
}
