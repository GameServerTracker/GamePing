//
//  CustomServerIcon.swift
//  GameStatus
//
//  Created by Tom on 28/09/2025.
//

import SwiftUI

struct CustomServerIcon: Hashable, Codable {
    let name: String
    let imageName: String
    var size: CGFloat = 32
}

let customServerIcons: [CustomServerIcon] = [
    .init(name: "Default", imageName: "serverLogo"),
    .init(name: "GamePing", imageName: "gstLogo"),
    .init(name: "Minecraft", imageName: "creeper"),
    .init(name: "CS 1.6", imageName: "cs", size: 52),
    .init(name: "CS:GO", imageName: "csgo", size: 52),
    .init(name: "Garry's Mod", imageName: "gmod", size: 52),
    .init(name: "Half Life", imageName: "hl", size: 52),
    .init(name: "Team Fortress", imageName: "tf", size: 52),
    .init(name: "Source", imageName: "source_icon", size: 52),
    .init(name: "Steam", imageName: "steam", size: 52),
    .init(name: "GTA V", imageName: "gta5", size: 52),
    .init(name: "FiveM", imageName: "fivem", size: 52),
    .init(name: "Rust", imageName: "rust", size: 52)
]
