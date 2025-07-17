//
//  GameServerType.swift
//  GameStatus
//
//  Created by Tom on 21/06/2025.
//

enum GameServerType: String, CaseIterable, Identifiable, Codable {
    case minecraft = "minecraft"
    case bedrock = "bedrock"
    case source = "source"
    case fivem = "fivem"
    case unknown = "n/a"
    
    var id: Self { self }
}

let gameServerTypesDisplayName: [String: String] = [
    GameServerType.minecraft.rawValue: "Minecraft",
    GameServerType.bedrock.rawValue: "Minecraft Bedrock",
    GameServerType.source.rawValue: "Source",
    GameServerType.fivem.rawValue: "FiveM",
    GameServerType.unknown.rawValue: "Unknown",
];

let gameServerTypesIconName: [String: String] = [
    GameServerType.minecraft.rawValue: "minecraft_icon",
    GameServerType.bedrock.rawValue: "minecraft_icon",
    GameServerType.source.rawValue: "source_icon",
    GameServerType.fivem.rawValue: "fivem_icon",
    GameServerType.unknown.rawValue: "questionmark.circle.fill",
];

let gameServerOsTypesIconName: [String: String] = [
    "windows": "windows_icon",
    "linux": "linux_icon",
    "mac": "apple.logo",
];

let gameServerTypesPort: [String: Int] = [
    GameServerType.minecraft.rawValue: 25565,
    GameServerType.bedrock.rawValue: 19132,
    GameServerType.source.rawValue: 27015,
    GameServerType.fivem.rawValue: 30120,
    GameServerType.unknown.rawValue: 0,
];
