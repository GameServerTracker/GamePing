//
//  GameServerType.swift
//  GameStatus
//
//  Created by Tom on 21/06/2025.
//

enum GameServerType: String, CaseIterable, Identifiable, Codable {
    case minecraft = "mc"
    case bedrock = "mcb"
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
    GameServerType.fivem.rawValue: "fivem",
    GameServerType.unknown.rawValue: "questionmark.circle.fill",
];

let gameServerOsTypesIconName: [String: String] = [
    "w": "windows_icon",
    "l": "linux_icon",
    "m": "apple.logo",
];

let gameServerOsTypesName: [String: String] = [
    "w": "Windows",
    "l": "Linux",
    "m": "macOS",
];

let gameServerTypesPort: [String: Int] = [
    GameServerType.minecraft.rawValue: 25565,
    GameServerType.bedrock.rawValue: 19132,
    GameServerType.source.rawValue: 27015,
    GameServerType.fivem.rawValue: 30120,
    GameServerType.unknown.rawValue: 0,
];
