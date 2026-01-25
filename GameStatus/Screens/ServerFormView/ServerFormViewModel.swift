//
//  ServerFormViewModel.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI
import SwiftData

enum ServerSaveAction {
    case add
    case edit
}

final class ServerFormViewModel: ObservableObject {
    private let server: GameServer?

    @Published var serverName: String = ""
    @Published var serverAddress: String = ""
    @Published var serverPort: Int? = nil
    @Published var serverType: GameServerType = .minecraft
    
    @Published var bgColor: Color = .blue
    @Published var fgColor: Color = .white
    @Published var iconName: String  = "serverLogo"
    
    @Published var serverIconIgnore: Bool = false
    
    @Published var isIconEditedSheetPresented: Bool = false
    
    init(server: GameServer? = nil) {
        self.server = server
        if let server = server {
            self.serverName = server.name
            self.serverAddress = server.address
            self.serverPort = server.port
            self.serverType = GameServerType(rawValue: server.type) ?? .minecraft
            self.bgColor = (server.iconBgColor != nil) ? Color(hex: server.iconBgColor!) : .blue
            self.fgColor = (server.iconFgColor != nil) ? Color(hex: server.iconFgColor!) : .white
            self.iconName = server.iconName ?? "serverLogo"
            self.serverIconIgnore = server.serverIconIgnore
        }
    }
    
    public var isValid: Bool {
        return !serverName.isEmpty && !serverAddress.isEmpty
    }
    
    public func save(context: ModelContext) -> ServerSaveAction {
        if let port = serverPort, !isValidPort(port) {
            serverPort = nil
        }
        
        if (server != nil) {
            server!.name = self.serverName
            server!.address = self.serverAddress
            server!.port = self.serverPort ?? gameServerTypesPort[self.serverType.rawValue] ?? 0
            server!.type = self.serverType.rawValue
            server!.iconBgColor = self.bgColor.hex
            server!.iconFgColor = self.fgColor.hex
            server!.iconName = self.iconName
            server!.serverIconIgnore = self.serverIconIgnore
            return .edit
        }
        let newServer: GameServer = GameServer(
            name: self.serverName,
            address: self.serverAddress,
            port: self.serverPort ?? gameServerTypesPort[self.serverType.rawValue] ?? 0,
            type: self.serverType,
            image: nil,
            iconBgColor: self.bgColor.hex,
            iconFgColor: self.fgColor.hex,
            iconName: self.iconName,
            serverIconIgnore: self.serverIconIgnore
        )
        context.insert(newServer)
        return .add
    }
    
    private func isValidPort(_ port: Int) -> Bool {
        return (port >= 0 && port <= 65535)
    }
}

