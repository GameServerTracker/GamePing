//
//  NetworkManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

final class NetworkManager {
    static let baseURL = "https://api.gameservertracker.io"
    
    static func fetchServerData(address: String, port: Int, type: GameServerType) async throws -> ServerStatus {
        var entrypoint: String? = nil

        switch type {
            case .minecraft:
                entrypoint = "minecraft"
                break
            case .bedrock:
                entrypoint = "minecraft/bedrock"
                break
            case .source:
                entrypoint = "source"
                break
        case .fivem:
            entrypoint = "fivem"
            break
        default:
            throw GameStatusException.invalidGameServerType("Invalid game server type: \(type)")
        }
        
        let url = URL(string: "\(Self.baseURL)/\(entrypoint!)/\(address):\(port)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let decoded = try GameServerResponse.from(data: data, type: type)
            return decoded.unified
        } catch {
            print("Failed to decode response: \(error)")
            throw error
        }
    }
}
