//
//  ServerStatusManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

@MainActor

class ServerStatusManager: ObservableObject {
    @Published var responses: [UUID: ServerStatus] = [:];
    private var clients: [UUID: Sendable] = [:];
    
    func getResponse(for server: GameServer) -> ServerStatus? {
        responses[server.id]
    }
    
    func fetchStatus(for server: GameServer) async {
        switch server.type {
        case GameServerType.source.rawValue:
            await fetchSourceStatus(for: server)
            break
        case GameServerType.bedrock.rawValue:
            await fetchBedrockStatus(for: server)
            break
        case GameServerType.minecraft.rawValue:
            await fetchMinecraftStatus(for: server)
            break
        case GameServerType.fivem.rawValue:
            await fetchFivemStatus(for: server)
            break
        default:
            print("[\(server.name)][\(server.type)] Server type not supported")
            break
        }
    }

    private func fetchMinecraftStatus(for server: GameServer) async {
        let client = TCPClient(
            host: server.address,
            port: UInt16(server.port),
        )
        self.clients[server.id] = client
        
        var info: String?
        var ping: UInt64? = nil
        
        func sendWithTimeout(_ type: TCPResponseType, timeout: TimeInterval, completion: @escaping () -> Void) {
            var responded: Bool = false

            client.onResponse = { response in
                switch (response) {
                case (.status):
                    responded = true
                    ping = client.ping
                default : break
                }
                switch response {
                case .status(let i): info = i
                default: break
                }
                completion()
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !responded {
                    completion()
                }
            }
        }
        client.onReady = {
            sendWithTimeout(.pong, timeout: 3) {
                self.getMinecraftResponse(info: info, ping: ping, serverId: server.id)
                client.stop()
            }
        }
        client.onFail = {
            DispatchQueue.main.async {
                self.responses[server.id] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
        client.start()
    }
    
    private func fetchBedrockStatus(for server: GameServer) async {
        let client = UDPClient(
            host: server.address,
            port: UInt16(server.port),
            messageType: .MC_UNCONNECTED_PING
        )
        self.clients[server.id] = client
        
        var info: MinecraftBedrockUnconnectedPong?
        var ping: UInt64? = nil
        
        func sendWithTimeout(_ type: QueryRequestType, timeout: TimeInterval, completion: @escaping () -> Void) {
            var responded: Bool = false
            
            client.setMessageType(type)
            client.onResponse = { response in
                switch (type, response) {
                case (.MC_UNCONNECTED_PING, .mcUnconnectedPong):
                    responded = true
                    ping = client.ping
                default : break
                }
                switch response {
                case .mcUnconnectedPong(let i): info = i
                default: break
                }
                completion()
            }
            client.clear()
            client.send()

            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !responded {
                    completion()
                }
            }
        }
        client.onReady = {
            sendWithTimeout(.MC_UNCONNECTED_PING, timeout: 3) {
                self.getBedrockResponse(info: info, ping: ping, serverId: server.id)
                client.stop()
            }
        }
        client.onFail = {
            DispatchQueue.main.async {
                self.responses[server.id] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
        client.start()
    }
    
    private func fetchSourceStatus(for server: GameServer) async {
        let client = UDPClient(
            host: server.address,
            port: UInt16(server.port),
            messageType: .A2S_INFO
        )
        self.clients[server.id] = client

        var info: SourceA2SInfo?
        var players: SourceA2SPlayer?
        var gotA2sInfo: Bool = false
        var ping: UInt64? = nil
        
        func sendWithTimeout(_ type: QueryRequestType, timeout: TimeInterval, completion: @escaping () -> Void) {
            var responded: Bool = false

            client.setMessageType(type)
            client.onResponse = { response in
                switch (type, response) {
                case (.A2S_INFO, .info),
                     (.A2S_PLAYER, .player),
                     (.A2S_RULES, .rules):
                    responded = true
                default:
                    return
                }

                if type == .A2S_INFO {
                    ping = client.ping
                    gotA2sInfo = true
                }

                switch response {
                case .info(let i): info = i
                case .player(let p): players = p
                default: break
                }
                completion()
            }
            client.clear()
            client.send()

            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !responded {
                    completion()
                }
            }
        }

        client.onReady = {
            sendWithTimeout(.A2S_INFO, timeout: 3) {
                if !gotA2sInfo {
                    DispatchQueue.main.async {
                        self.getSourceResponse(info: nil, player: nil, ping: nil, serverId: server.id)
                    }
                    client.stop()
                    return
                }
                sendWithTimeout(.A2S_PLAYER, timeout: 3) {
                    self.getSourceResponse(info: info, player: players, ping: ping, serverId: server.id)
                    print("Finish fetch")
                    client.stop()
                }
            }
        }
        client.onFail = {
            DispatchQueue.main.async {
                self.responses[server.id] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
        client.start()
    }
    
    private func fetchFivemStatus(for server: GameServer) async {
        let dynamic: FiveMServerResponse? = await NetworkManager.fetchFiveMDynamic(address: server.address, port: server.port)
        let info: FivemInfoResponse?  = await NetworkManager.fetchFiveMInfo(address: server.address, port: server.port)
        let players: [FivemPlayer]? = await NetworkManager.fetchFiveMPlayers(address: server.address, port: server.port)
        
        if dynamic == nil || dynamic?.online == false {
            self.responses[server.id] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            return;
        }
        
        let playersMax: Int? = {
            if let max = dynamic?.sv_maxclients {
                return Int(max)
            }
            return nil
        }()
        
        let keywords: [String]? = {
            if let tags = info?.vars?.tags {
                return tags.components(separatedBy: ", ")
            }
            return nil
        }()
        let playersList = players.map { $0.map(\.name) } ?? []
        let status = ServerStatus(
            online: true,
            playersOnline: dynamic?.clients,
            playersMax: playersMax,
            players: playersList,
            name: info?.vars?.projectName,
            game: dynamic?.gametype,
            motd: nil,
            map: dynamic?.mapname,
            version: info?.server,
            ping: nil,
            favicon: info?.icon,
            os: nil,
            keywords: keywords,
        )
        print(status)
        self.responses[server.id] = status
    }
    
    private func getSourceResponse(info: SourceA2SInfo?, player: SourceA2SPlayer?, ping: UInt64?, serverId: UUID) {
        DispatchQueue.main.async {
            if let info = info {
                let players = player?.players.map { $0.name } ?? []
                let serverPing = (ping != nil) ? Int(ping!) : nil
                
                self.responses[serverId] = .init(online: true, playersOnline: Int(info.players), playersMax: Int(info.maxPlayers), players: players, name: info.name, game: info.game, motd: nil, map: info.map, version: info.version, ping: serverPing, favicon: nil, os: String(info.os), keywords: info.keywords)
            } else {
                self.responses[serverId] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
    }
    
    private func getMinecraftResponse(info: String?, ping: UInt64?, serverId: UUID) {
        DispatchQueue.main.async {
            if let info = info {
                print(info)
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(
                        MinecraftPong.self,
                        from: info.data(using: .utf8)!
                    )
                    let serverPing = (ping != nil) ? Int(ping!) : nil
                    let players: [String] = response.players.sample?.map { $0.name } ?? []
                    self.responses[serverId] = .init(online: true, playersOnline: response.players.online, playersMax: response.players.max, players: players, name: nil, game: nil, motd: nil, map: nil, version: response.version.name, ping: serverPing, favicon: response.favicon, os: nil, keywords: nil)
                } catch {
                    print("Failed to decode response: \(error)")
                    self.responses[serverId] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
                }
            } else {
                self.responses[serverId] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
    }
    
    private func getBedrockResponse(info: MinecraftBedrockUnconnectedPong?, ping: UInt64?, serverId: UUID) {
        DispatchQueue.main.async {
            if let info = info {
                let serverPing = (ping != nil) ? Int(ping!) : nil
                self.responses[serverId] = .init(online: true, playersOnline: Int(info.players), playersMax: Int(info.maxPlayers), players: nil, name: nil, game: info.gamemode, motd: info.motd, map: nil, version: info.version.name, ping: serverPing, favicon: nil, os: nil, keywords: nil)
            } else {
                self.responses[serverId] = .init(online: false, playersOnline: nil, playersMax: nil, players: nil, name: nil, game: nil, motd: nil, map: nil, version: nil, ping: nil, favicon: nil, os: nil, keywords: nil)
            }
        }
    }
    
    func fetchAllStatuses(for servers: [GameServer]) async {
        Task {
            for server in servers {
                await fetchStatus(for: server)
            }
        }
    }
}
