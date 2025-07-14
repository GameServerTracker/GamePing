//
//  FivemServer.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

struct FiveMServerResponse: Codable {
    let address: String
    let online: Bool
    let clients: Int?
    let gametype: String?
    let hostname: String?
    let iv: String?
    let mapname: String?
    let sv_maxclients: String?
}
