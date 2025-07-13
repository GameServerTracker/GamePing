//
//  GameServerType.swift
//  GameStatus
//
//  Created by Tom on 21/06/2025.
//

enum GameServerType: String, CaseIterable, Identifiable, Codable {
    case minecraft = "mc"
    case minecraftBedrock = "mcbd"
    case source = "source"
    case fivem = "fivem"
    case unknown = "n/a"
    
    var id: Self { self }
}

let gameServerTypesDisplayName: [String: String] = [
    GameServerType.minecraft.rawValue: "Minecraft",
    GameServerType.minecraftBedrock.rawValue: "Minecraft Bedrock",
    GameServerType.source.rawValue: "Source",
    GameServerType.fivem.rawValue: "FiveM",
    GameServerType.unknown.rawValue: "Unknown",
];

let gameServerTypesIconName: [String: String] = [
    GameServerType.minecraft.rawValue: "minecraft_icon",
    GameServerType.minecraftBedrock.rawValue: "minecraft_icon",
    GameServerType.source.rawValue: "source_icon",
    GameServerType.fivem.rawValue: "fivem_icon",
    GameServerType.unknown.rawValue: "questionmark.circle.fill",
];

let gameServerTypesPort: [String: Int] = [
    GameServerType.minecraft.rawValue: 25565,
    GameServerType.minecraftBedrock.rawValue: 19132,
    GameServerType.source.rawValue: 27015,
    GameServerType.fivem.rawValue: 30120,
    GameServerType.unknown.rawValue: 0,
];
