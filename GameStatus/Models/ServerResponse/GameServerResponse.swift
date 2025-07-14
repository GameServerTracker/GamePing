//
//  GameServerResponse.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

enum GameServerResponse {
    case minecraft(MinecraftServerResponse)
    case bedrock(BedrockServerResponse)
    case source(SourceServerResponse)
    case fivem(FiveMServerResponse)
}

extension GameServerResponse {
    static func from(data: Data, type: GameServerType) throws
        -> GameServerResponse
    {
        let decoder = JSONDecoder()

        switch type {
        case .minecraft:
            let response = try decoder.decode(
                MinecraftServerResponse.self,
                from: data
            )
            return .minecraft(response)

        case .bedrock:
            let response = try decoder.decode(
                BedrockServerResponse.self,
                from: data
            )
            return .bedrock(response)

        case .source:
            let response = try decoder.decode(
                SourceServerResponse.self,
                from: data
            )
            return .source(response)

        case .fivem:
            let response = try decoder.decode(
                FiveMServerResponse.self,
                from: data
            )
            return .fivem(response)
        case .unknown:
            let response = try decoder.decode(
                MinecraftServerResponse.self,
                from: data
            )
            return .minecraft(response)
        }
    }

    var unified: ServerStatus {
        switch self {
        case .minecraft(let mc):
            return ServerStatus(
                online: mc.online,
                playersOnline: mc.players?.online,
                playersMax: mc.players?.max,
                players: mc.players?.playerNames,
                name: nil,
                game: nil,
                motd: mc.motd?.clean,
                map: nil,
                version: mc.version?.name,
                ping: mc.ping,
                favicon: mc.favicon,
                os: nil,
                keywords: nil,
                rawResponse: self
            )
        case .bedrock(let bd):
            return ServerStatus(
                online: bd.online,
                playersOnline: bd.players?.online,
                playersMax: bd.players?.max,
                players: nil,
                name: nil,
                game: bd.edition,
                motd: bd.motd?.clean,
                map: nil,
                version: bd.version?.name,
                ping: nil,
                favicon: nil,
                os: nil,
                keywords: nil,
                rawResponse: self
            )

        case .source(let sr):
            return ServerStatus(
                online: sr.online,
                playersOnline: sr.players?.online,
                playersMax: sr.players?.max,
                players: nil,
                name: sr.name,
                game: sr.game,
                motd: nil,
                map: sr.map,
                version: sr.version,
                ping: sr.ping,
                favicon: nil,
                os: sr.os,
                keywords: sr.keywords,
                rawResponse: self
            )
        case .fivem(let fm):
            return ServerStatus(
                online: fm.online,
                playersOnline: fm.clients,
                playersMax: Int(fm.sv_maxclients ?? "0"),
                players: nil,
                name: fm.hostname,
                game: fm.gametype,
                motd: nil,
                map: fm.mapname,
                version: nil,
                ping: nil,
                favicon: nil,
                os: nil,
                keywords: nil,
                rawResponse: self
            )
        }
    }
}
