//
//  ServerFormViewModel.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI
import SwiftData

final class ServerFormViewModel: ObservableObject {
    private let server: GameServer?

    @Published var serverName: String = ""
    @Published var serverAddress: String = ""
    @Published var serverPort: Int? = nil
    @Published var serverType: GameServerType = .minecraft
    
    init(server: GameServer? = nil) {
        self.server = server
        if let server = server {
            self.serverName = server.name
            self.serverAddress = server.address
            self.serverPort = server.port
            self.serverType = GameServerType(rawValue: server.type) ?? .minecraft
        }
    }
    
    public func save(context: ModelContext) {
        if (server != nil) {
            server!.name = self.serverName
            server!.address = self.serverAddress
            server!.port = self.serverPort ?? gameServerTypesPort[self.serverType.rawValue] ?? 0
            server!.type = self.serverType.rawValue
            return
        }
        let newServer: GameServer = GameServer(
            name: self.serverName,
            address: self.serverAddress,
            port: self.serverPort ?? gameServerTypesPort[self.serverType.rawValue] ?? 0,
            type: self.serverType,
            image: nil
        )
        context.insert(newServer)
    }
}
