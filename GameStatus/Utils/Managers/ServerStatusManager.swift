//
//  ServerStatusManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

@MainActor
class ServerStatusManager: ObservableObject {
    @Published var responses: [UUID: ServerStatus] = [:]
    private var clients: [UUID: Sendable] = [:]
    private var inflightTasks: [UUID: Task<Void, Never>] = [:]

    private struct ProtocolAttempt {
        let type: GameServerType
        let action: () async -> Void
    }

    func getResponse(for server: GameServer) -> ServerStatus? {
        responses[server.id]
    }

    func fetchStatus(for server: GameServer) async {
        let id = server.id
        if let existing = inflightTasks[id] {
            print(
                "[\(server.name)][\(server.type)] Fetch is already in progress"
            )
            _ = await existing.value
            return
        }

        // Create a new task responsible for performing the actual fetch based on server type
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performFetch(for: server)
        }
        inflightTasks[id] = task

        // Await completion, then clear inflight entry
        _ = await task.value
        inflightTasks[id] = nil
    }

    private func performFetch(for server: GameServer) async {
        switch server.type {
        case GameServerType.auto.rawValue:
            await fetchAutomaticStatus(for: server)
        case GameServerType.source.rawValue:
            await fetchSourceStatus(for: server)
        case GameServerType.bedrock.rawValue:
            await fetchBedrockStatus(for: server)
        case GameServerType.minecraft.rawValue:
            await fetchMinecraftStatus(for: server)
        case GameServerType.fivem.rawValue:
            await fetchFivemStatus(for: server)
        case GameServerType.fivemctx.rawValue:
            await fetchFivemCtxStatus(for: server)
        default:
            print("[\(server.name)][\(server.type)] Server type not supported")
            responses[server.id] = .offline
        }
    }

    private func fetchAutomaticStatus(for server: GameServer) async {
        print("[\(server.name)] Starting Auto-Mode detection...")

        let fetchers: [ProtocolAttempt] = [
            ProtocolAttempt(
                type: .minecraft,
                action: { await self.fetchMinecraftStatus(for: server) }
            ),
            ProtocolAttempt(
                type: .bedrock,
                action: { await self.fetchBedrockStatus(for: server) }
            ),
            ProtocolAttempt(
                type: .source,
                action: { await self.fetchSourceStatus(for: server) }
            ),
            ProtocolAttempt(
                type: .fivem,
                action: { await self.fetchFivemStatus(for: server) }
            ),
        ]

        let sortedTasks = fetchers.sorted {
            calculateAutoPriority(for: $0.type, server: server)
                > calculateAutoPriority(for: $1.type, server: server)
        }

        print(
            "[\(server.name)] Starting Auto-Mode with order: \(sortedTasks.map { $0.type })"
        )
        for sortedTask in sortedTasks {
            await sortedTask.action()

            if let status = responses[server.id], status.online {
                print("[\(server.name)] server type detected as: \(sortedTask.type.rawValue), update server.type")
                server.type = sortedTask.type.rawValue
                
                if (server.port == 0) {
                    switch sortedTask.type {
                    case .minecraft:
                        server.port = 25565
                    case .bedrock:
                        server.port = 19132
                    case .source:
                        server.port = 27015
                    case .fivem:
                        server.port = 30125
                    default: break
                    }
                }
                return
            } else {
                responses[server.id] = nil
            }
        }
        responses[server.id] = .offline
        print("[\(server.name)] Could not determine server type")
    }

    private func calculateAutoPriority(
        for type: GameServerType,
        server: GameServer
    ) -> Int {
        var score: Int = 0
        let port: Int = Int(server.port)
        let name: String = server.name.lowercased()

        switch type {
        case .minecraft:
            if port == 25565 { score += 100 }
            if (25565...25600).contains(port) { score += 50 }
            if name.contains("mc") { score += 50 }
        case .bedrock:
            if port == 19132 { score += 100 }
            if name.contains("bedrock") { score += 50 }
        case .source:
            if [27015, 27016, 27050].contains(port) { score += 100 }
        case .fivem:
            if port == 30120 { score += 100 }
            if name.contains("gta") || name.contains("red") { score += 50 }
            if name.contains("rp") || name.contains("roleplay") { score += 20 }
        default:
            break
        }
        return score
    }

    private func fetchMinecraftStatus(for server: GameServer) async {
        // Default port
        let port = server.port == 0 ? 25565 : server.port

        let client = TCPClient(
            host: server.address,
            port: UInt16(min(max(port, 0), 65535)),
        )
        self.clients[server.id] = client

        var info: String?
        var ping: UInt64? = nil

        func sendWithTimeout(
            _ type: TCPResponseType,
            timeout: TimeInterval,
            completion: @escaping () -> Void
        ) {
            var responded: Bool = false

            client.onResponse = { response in
                switch response {
                case (.status):
                    responded = true
                    ping = client.ping
                default: break
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
        
        await withCheckedContinuation { continuation in
            var isResumed = false
            let resumeTask = {
                if !isResumed {
                    isResumed = true
                    continuation.resume()
                }
            }

            client.onReady = {
                sendWithTimeout(.pong, timeout: 3) {
                    self.getMinecraftResponse(
                        info: info,
                        ping: ping,
                        serverId: server.id
                    )
                    client.stop()
                    resumeTask()
                }
            }
            client.onFail = {
                DispatchQueue.main.async {
                    self.responses[server.id] = .offline
                }
                resumeTask()
            }
            client.start()
        }
    }

    private func fetchBedrockStatus(for server: GameServer) async {
        // Default port
        let port = server.port == 0 ? 19132 : server.port

        let client = UDPClient(
            host: server.address,
            port: UInt16(min(max(port, 0), 65535)),
            messageType: .MC_UNCONNECTED_PING
        )
        self.clients[server.id] = client

        var info: MinecraftBedrockUnconnectedPong?
        var ping: UInt64? = nil

        func sendWithTimeout(
            _ type: QueryRequestType,
            timeout: TimeInterval,
            completion: @escaping () -> Void
        ) {
            var responded: Bool = false

            client.setMessageType(type)
            client.onResponse = { response in
                switch (type, response) {
                case (.MC_UNCONNECTED_PING, .mcUnconnectedPong):
                    responded = true
                    ping = client.ping
                default: break
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
        
        await withCheckedContinuation { continuation in
            var isResumed = false
            let resumeTask = {
                if !isResumed {
                    isResumed = true
                    continuation.resume()
                }
            }

            client.onReady = {
                sendWithTimeout(.MC_UNCONNECTED_PING, timeout: 3) {
                    self.getBedrockResponse(
                        info: info,
                        ping: ping,
                        serverId: server.id
                    )
                    client.stop()
                    resumeTask()
                }
            }
            client.onFail = {
                DispatchQueue.main.async {
                    self.responses[server.id] = .offline
                }
                resumeTask()
            }
            client.start()
        }
    }

    private func fetchSourceStatus(for server: GameServer) async {
        // Default port
        let port = server.port == 0 ? 27015 : server.port

        let client = UDPClient(
            host: server.address,
            port: UInt16(min(max(port, 0), 65535)),
            messageType: .A2S_INFO
        )
        self.clients[server.id] = client

        var info: SourceA2SInfo?
        var players: SourceA2SPlayer?
        var ping: UInt64? = nil

        func sendWithTimeout(
            _ type: QueryRequestType,
            timeout: TimeInterval,
            completion: @escaping () -> Void
        ) {
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

        await withCheckedContinuation { continuation in
            var isResumed = false
            let resumeTask = {
                if !isResumed {
                    isResumed = true
                    continuation.resume()
                }
            }

            client.onReady = {
                sendWithTimeout(.A2S_INFO, timeout: 3) {
                    guard info != nil else {
                        DispatchQueue.main.async {
                            self.getSourceResponse(
                                info: nil,
                                player: nil,
                                ping: nil,
                                serverId: server.id
                            )
                        }
                        client.stop()
                        resumeTask()
                        return
                    }
                    sendWithTimeout(.A2S_PLAYER, timeout: 3) {
                        self.getSourceResponse(
                            info: info,
                            player: players,
                            ping: ping,
                            serverId: server.id
                        )
                        client.stop()
                        resumeTask()
                    }
                }
            }
            client.onFail = {
                DispatchQueue.main.async {
                    self.responses[server.id] = .offline
                }
                resumeTask()
            }
            client.start()
        }
    }

    private func fetchFivemStatus(for server: GameServer) async {
        let port = server.port == 0 ? 30120 : server.port
        let dynamic: FiveMServerResponse? =
            await NetworkManager.fetchFiveMDynamic(
                address: server.address,
                port: port
            )
        let info: FivemInfoResponse? = await NetworkManager.fetchFiveMInfo(
            address: server.address,
            port: port
        )
        let players: [FivemPlayer]? = await NetworkManager.fetchFiveMPlayers(
            address: server.address,
            port: port
        )

        if dynamic == nil || dynamic?.online == false {
            self.responses[server.id] = .offline
            return
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
        let playersList: [ServerPlayerInfo] =
            players?.map {
                ServerPlayerInfo(
                    name: $0.name,
                    score: nil,
                    duration: nil,
                    ping: $0.ping
                )
            } ?? []
        let status = ServerStatus(
            online: true,
            playersOnline: dynamic?.clients,
            playersMax: playersMax,
            players: playersList,
            name: dynamic?.hostname,
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
    
    private func fetchFivemCtxStatus(for server: GameServer) async {
        let info: FivemCtxResponse? = await NetworkManager.fetchFiveMCtx(code: server.address)
        
        if let info {
            let keywords: [String]? = {
                if let tags = info.data.vars.tags {
                    return tags.components(separatedBy: ", ")
                }
                return nil
            }()
            let image: String? = await NetworkManager.getFivemFavicons(code: server.address, version: info.data.iconVersion)
            self.responses[server.id] = .init(
                online: true,
                playersOnline: info.data.clients,
                playersMax: info.data.svMaxclients,
                players: info.data.players.map {
                    ServerPlayerInfo(
                        name: $0.name,
                        score: nil,
                        duration: nil,
                        ping: $0.ping
                    )
                },
                name: info.data.hostname,
                game: info.data.gametype,
                motd: nil,
                map: info.data.mapname,
                version: info.data.server,
                ping: nil,
                favicon: image,
                os: nil,
                keywords: keywords
            )
        } else {
            self.responses[server.id] = .offline
        }
    }

    private func getSourceResponse(
        info: SourceA2SInfo?,
        player: SourceA2SPlayer?,
        ping: UInt64?,
        serverId: UUID
    ) {
        DispatchQueue.main.async {
            if let info = info {
                let playersList: [ServerPlayerInfo] =
                    player?.players.map {
                        ServerPlayerInfo(
                            name: $0.name,
                            score: Int($0.score),
                            duration: Int($0.duration),
                            ping: nil
                        )
                    } ?? []

                let serverPing = (ping != nil) ? Int(ping!) : nil

                self.responses[serverId] = .init(
                    online: true,
                    playersOnline: Int(info.players),
                    playersMax: Int(info.maxPlayers),
                    players: playersList,
                    name: info.name,
                    game: info.game,
                    motd: nil,
                    map: info.map,
                    version: info.version,
                    ping: serverPing,
                    favicon: nil,
                    os: String(info.os),
                    keywords: info.keywords
                )
            } else {
                self.responses[serverId] = .offline
            }
        }
    }

    private func getMinecraftResponse(
        info: String?,
        ping: UInt64?,
        serverId: UUID
    ) {
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
                    let playersList: [ServerPlayerInfo] =
                        response.players.sample?.map {
                            ServerPlayerInfo(
                                name: $0.name,
                                score: nil,
                                duration: nil,
                                ping: nil
                            )
                        } ?? []
                    let motd = response.description.getAttributedString()
                    self.responses[serverId] = .init(
                        online: true,
                        playersOnline: response.players.online,
                        playersMax: response.players.max,
                        players: playersList,
                        name: nil,
                        game: nil,
                        motd: motd,
                        map: nil,
                        version: response.version.name,
                        ping: serverPing,
                        favicon: response.favicon,
                        os: nil,
                        keywords: nil
                    )
                } catch {
                    print("Failed to decode response: \(error)")
                    self.responses[serverId] = .offline
                }
            } else {
                self.responses[serverId] = .offline
            }
        }
    }

    private func getBedrockResponse(
        info: MinecraftBedrockUnconnectedPong?,
        ping: UInt64?,
        serverId: UUID
    ) {
        DispatchQueue.main.async {
            if let info = info {
                let serverPing = (ping != nil) ? Int(ping!) : nil
                self.responses[serverId] = .init(
                    online: true,
                    playersOnline: Int(info.players),
                    playersMax: Int(info.maxPlayers),
                    players: nil,
                    name: nil,
                    game: info.gamemode,
                    motd: MinecraftMotd.renderString(info.motd),
                    map: nil,
                    version: info.version.name,
                    ping: serverPing,
                    favicon: nil,
                    os: nil,
                    keywords: nil
                )
            } else {
                self.responses[serverId] = .offline
            }
        }
    }

    func fetchAllStatuses(for servers: [GameServer]) async {
        let tasks = servers.map { server in
            Task {
                await self.fetchStatus(for: server)
            }
        }
        for task in tasks {
            await task.value
        }
    }
}
