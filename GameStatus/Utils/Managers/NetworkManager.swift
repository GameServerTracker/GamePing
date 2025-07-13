//
//  NetworkManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

final class NetworkManager {
    static let baseURL = "https://api.gameservertracker.io"
    
    static func fetchServerData(address: String, port: Int, type: GameServerType) async throws -> GameServerResponse {
        let url = URL(string: "\(Self.baseURL)/minecraft/\(address):\(port)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        print(data)
        
        let decoded = try JSONDecoder().decode(GameServerResponse.self, from: data)
        return decoded
    }
}
