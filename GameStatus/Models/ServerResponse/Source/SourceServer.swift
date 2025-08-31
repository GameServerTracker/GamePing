//
//  SourceServer.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

struct SourceServerResponse: Codable {
    let address: String
    let port: Int
    let online: Bool
    let protocolNumber: Int?
    let goldSource: Bool?
    let name: String?
    let map: String?
    let folder: String?
    let game: String?
    let appID: String?
    let players: SourcePlayers?
    let type: String?
    let os: String?
    let visibility: String?
    let vac: Bool?
    let version: String?
    let steamID: String?
    let keywords: [String]?
    let gameID: String?
    let ping: Int?

    enum CodingKeys: String, CodingKey {
        case address, protocolNumber = "protocol", goldSource, name, map, folder, game, appID,
             players, type, os = "OS", visibility, vac = "VAC", version, port, steamID,
             keywords, gameID, online, ping
    }
}

struct SourcePlayers: Codable {
    let online: Int
    let max: Int
    let bots: Int
}
