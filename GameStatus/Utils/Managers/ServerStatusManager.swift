//
//  ServerStatusManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

@MainActor

class ServerStatusManager: ObservableObject {
    @Published var responses: [UUID: GameServerResponse] = [:];
    
    func getResponse(for server: GameServer) -> GameServerResponse? {
        responses[server.id]
    }
    
    func fetchStatus(for server: GameServer) async {
        do {
            let response = try await NetworkManager.fetchServerData(address: server.address, port: server.port, type: .minecraft)
            responses[server.id] = response
        } catch {
            print("[\(server.name)] Erreur fetch status: \(error)")
        }
    }
    
    func fetchAllStatuses(for servers: [GameServer]) async {
        Task {
            for server in servers {
                await fetchStatus(for: server)
            }
        }
    }
}
