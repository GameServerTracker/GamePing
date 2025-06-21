//
//  GameServerType.swift
//  GameStatus
//
//  Created by Tom on 21/06/2025.
//

enum GameServerType: String, CaseIterable, Identifiable {
    case minecraft = "mc"
    case minecraftBedrock = "mcbd"
    case source = "source"
    case fivem = "fivem"
    case unknown = "n/a"
    
    var id: Self { self }
}
