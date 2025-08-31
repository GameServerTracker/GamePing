//
//  MinecraftServerResponse.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

struct MinecraftServerResponse: Codable {
    let address: String
    let port: Int
    let online: Bool
    let version: MinecraftVersion?
    let players: MinecraftPlayers?
    let motd: MinecraftMOTD?
    let favicon: String?
    let ping: Int?
}

struct BedrockServerResponse: Codable {
    let address: String
    let port: Int
    let online: Bool
    let edition: String
    let motd: MinecraftMOTD?
    let version: MinecraftVersion?
    let players: BedrockPlayers?
    let serverGUID: String?
    let serverID: String?
    let gameMode: String?
    let gameModeID: Int?
    let portIPv4: Int?
    let portIPv6: Int?
}

struct BedrockPlayers: Codable {
    let online: Int
    let max: Int
}

struct MinecraftVersion: Codable {
    let name: String
    let `protocol`: Int
}

struct MinecraftPlayers: Codable {
    let online: Int
    let max: Int
    let sample: [MinecraftPlayerData]?
    
    struct MinecraftPlayerData: Codable {
        let name: String
    }
}

struct MinecraftMOTD: Codable {
    let raw: String
    let clean: String
    let html: String
}

extension MinecraftPlayers {
    var playerNames: [String] {
        sample?.map { $0.name } ?? []
    }
}
