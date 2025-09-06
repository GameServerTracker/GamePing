//
//  UDPClient.swift
//  UDPClient
//
//  Created by Tom on 17/07/2025.
//

import Foundation
import Network

enum QueryRequestType {
    case A2S_INFO
    case A2S_PLAYER
    case A2S_RULES

    case MC_UNCONNECTED_PING
}

// Each instance is isolated to a single Task and not shared between threads.
// Safe to mark @unchecked Sendable.
final class UDPClient: @unchecked Sendable {
    private struct SplitAssembly {
        let total: UInt8
        var parts: [UInt8: Data] = [:]
    }

    private var splitAssemblies: [UInt32: SplitAssembly] = [:]
    private let queue = DispatchQueue(label: "UDPClient.SerialQueue")

    private let connection: NWConnection

    private var sentTimestamp: UInt64?
    private let address: String
    private let port: UInt16

    public var messageType: QueryRequestType
    public var ping: UInt64?
    public var onResponse: ((QueryResponseType) -> Void)?

    init(
        host: String,
        port: UInt16,
        messageType: QueryRequestType
    ) {
        self.messageType = messageType
        self.address = host
        self.port = port
        connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port),
            using: .udp
        )
    }

    public var onReady: (() -> Void)?
    public var onFail: (() -> Void)?
    private var hasStartedReceiving = false

    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            self.printLog("Client state: \(state)")
            switch state {
            case .ready:
                if !self.hasStartedReceiving {
                    self.hasStartedReceiving = true
                    self.receiveNext()
                }
                self.onReady?()
                break
            case .waiting(let error):
                switch error {
                case .dns(let dnsError):
                    self.printLog("DNS error: \(dnsError)")
                    self.onFail?()
                    self.stop()
                case .posix(let posixError):
                    self.printLog("POSIX error: \(posixError)")
                    self.stop()
                    self.onFail?()
                default:
                    self.printLog("Unhandled NWError: \(error)")
                }
            case .failed(let error):
                self.printLog("Client failed: \(error)")
                self.stop()
                self.onFail?()
                break
            case .cancelled:
                self.printLog("Connection cancelled")
            default:
                self.printLog("Client state: \(state)")
                break
            }
        }
        connection.start(queue: queue)
        print("Client Started")
    }

    func stop() {
        queue.async {
            self.connection.cancel()
            self.printLog("Client Stopped")
        }
    }

    func clear() {
        splitAssemblies.removeAll()
    }

    public func setMessageType(_ type: QueryRequestType) {
        queue.async { self.messageType = type }
    }

    func send(challenge: Data? = nil) {
        queue.async {
            guard self.connection.state == .ready else {
                self.printLog("WARN: Cannot send, connection not ready.")
                return
            }
            let packet: Data = self._formatPacket(
                type: self.messageType,
                challenge: challenge
            )
            self.printLog(
                "Message to send (\(self.messageType)): \(packet.hexDescription)"
            )
            self.sentTimestamp = UInt64(Date().timeIntervalSince1970 * 1000)
            self.connection.send(
                content: packet,
                completion: .contentProcessed({ error in
                    if let error = error {
                        self.printLog("Error sending: \(error)")
                    }
                })
            )
        }
    }

    private func receiveNext() {
        self.printLog("[\(self.address):\(self.port)] Wait for message...")
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) {
            data,
            _,
            isComplete,
            error in
            if let data = data {
                self.printLog("isComplete: \(isComplete)")
                self.handleReceivedData(data)
            } else if let error = error {
                self.printLog("Error receiving: \(error)")
            }

            if self.connection.state == .ready {
                self.receiveNext()
            }
        }
    }

    private func handleReceivedData(_ data: Data) {
        let (result, retry) = self.process(data: data)

        if retry {
            if case let .challenge(challengeData) = result {
                self.printLog("Retrying with challenge...")
                self.send(challenge: challengeData)
            }
        }

        if let sent = self.sentTimestamp {
            let now = UInt64(Date().timeIntervalSince1970 * 1000)
            self.ping = now - sent
            printLog("Ping RTT: \(self.ping!) ms")
        }

        switch result {
        case .info(let info):
            printLog("Info received: \(info)")
            DispatchQueue.main.async { self.onResponse?(result!) }
            break
        case .player(let player):
            print("Players online: \(player.players.count)")
            DispatchQueue.main.async { self.onResponse?(result!) }
            break
        case .rules(let rules):
            printLog("Rules: \(rules.rulesLength)")
            DispatchQueue.main.async { self.onResponse?(result!) }
            break
        case .challenge:
            printLog("Challenge received...")
        case .mcUnconnectedPong(let info):
            printLog("MC Data: \(info)")
            DispatchQueue.main.async { self.onResponse?(result!) }
            break
        default:
            printLog("Nothings received...")
        }
    }

    private func _formatPacket(type: QueryRequestType, challenge: Data? = nil)
        -> Data
    {
        var packet: Data = Data([0xFF, 0xFF, 0xFF, 0xFF])

        switch type {
        case .A2S_INFO:
            packet.append(0x54)
            packet.append("Source Engine Query".data(using: .utf8)!)
            packet.append(0x00)
            packet.append(contentsOf: challenge ?? Data([]))
            break
        case .A2S_PLAYER:
            packet.append(0x55)
            packet.append(
                contentsOf: challenge ?? Data([0xFF, 0xFF, 0xFF, 0xFF])
            )
            break
        case .A2S_RULES:
            packet.append(0x56)
            packet.append(
                contentsOf: challenge ?? Data([0xFF, 0xFF, 0xFF, 0xFF])
            )
            break
        // MC
        case .MC_UNCONNECTED_PING:
            var clientAliveTime: UInt64 = 5000
            let magic: Data = Data([
                0x00, 0xFF, 0xFF, 0x00, 0xFE, 0xFE, 0xFE, 0xFE, 0xFD, 0xFD,
                0xFD, 0xFD, 0x12, 0x34, 0x56, 0x78,
            ])
            var guid: UInt64 = .random(in: 0..<UInt64.max)
            packet = Data([0x01])
            packet.append(withUnsafeBytes(of: &clientAliveTime, { Data($0) }))
            packet.append(contentsOf: magic)
            packet.append(withUnsafeBytes(of: &guid, { Data($0) }))
        }
        return packet
    }

    func process(data: Data) -> (QueryResponseType?, Bool) {
        var payload: Data = data

        printLog(payload.hexDescription)
        guard payload.count >= 5
        else {
            printLog("Bad Payload")
            return (nil, false)
        }

        if let first = payload.first, first == 0xFE {
            self.printLog("Data split detected")
            guard let fullPayload = self.processSplitPacket(data: payload)
            else {
                self.printLog("Waiting for the remaining fragments...")
                return (nil, false)
            }
            payload = fullPayload
        } else if payload.prefix(4) != Data([0xFF, 0xFF, 0xFF, 0xFF])
            && payload.prefix(1) != Data([0x1C])
        {
            printLog("Invalid Header")
            return (nil, false)
        }

        if payload.prefix(1) != Data([0x1C]) {
            payload.removeFirst(4)
        }

        let header: UInt8 = payload.removeFirst()
        switch header {
        case QueryResponseHeader.info.rawValue:
            if let info: SourceA2SInfo = parseSourceA2SInfo(payload) {
                return (.info(info), false)
            } else {
                return (nil, false)
            }
        case QueryResponseHeader.player.rawValue:
            if let player: SourceA2SPlayer = parseSourceA2SPlayers(payload) {
                return (.player(player), false)
            } else {
                return (nil, false)
            }
        case QueryResponseHeader.rules.rawValue:
            if let rule: SourceA2SRules = parseSourceA2SRules(payload) {
                return (.rules(rule), false)
            } else {
                return (nil, false)
            }
        case QueryResponseHeader.challenge.rawValue:
            printLog(
                "Need to resend query with the following challenge value: \(payload.hexDescription)"
            )
            return (.challenge(payload), true)
        case QueryResponseHeader.mcUnconnectedPong.rawValue:
            return (
                .mcUnconnectedPong(
                    parseMinecraftBedrockUnconnectedPong(payload)
                ), false
            )
        default:
            print("Response not handled: \(header) / \(payload.hexDescription)")
            return (nil, false)
        }
    }

    func processSplitPacket(data: Data) -> Data? {
        var payload: Data = data

        // Strip split header (0xFE ...)
        payload.removeFirst(4)

        // Packet ID
        guard payload.count >= 4 else {
            printLog("\(#function): Missing packet ID")
            return nil
        }
        let packetId: UInt32 = payload.getUInt32LittleEndian()!

        // Total & index
        guard payload.count >= 1 else {
            printLog("\(#function): Missing Total")
            return nil
        }
        let total: UInt8 = payload.getUInt8()!
        guard payload.count >= 1 else {
            printLog("\(#function): Missing Idx")
            return nil
        }
        let index: UInt8 = payload.getUInt8()!

        // Size of this fragment's body
        guard payload.count >= 2 else {
            printLog("\(#function): Missing packet size")
            return nil
        }
        let size: UInt16 = payload.getUInt16()!

        var expectedTotal = total
        if (total & 0x80) != 0 {
            // High bit => compressed (bzip2). For A2S_PLAYER it is typically not used.
            expectedTotal = total & 0x7F
            if index == 0 {
                // First fragment carries two extra fields (8 bytes): decompressed size and CRC32.
                guard payload.count >= 8 else { return nil }
                _ = payload.getUInt32LittleEndian()
                _ = payload.getUInt32LittleEndian()
            }
        }

        // Body
        let body = payload.prefix(Int(size))

        // Insert into assembly for this packetId
        var asm =
            splitAssemblies[packetId] ?? SplitAssembly(total: expectedTotal)
        asm.parts[index] = Data(body)
        splitAssemblies[packetId] = asm

        printLog(
            "Fragments for \(packetId): \(asm.parts.count) / \(expectedTotal)"
        )

        guard asm.parts.count == Int(expectedTotal) else {
            return nil
        }

        // Reassemble in order
        var merged = Data()
        for i in 0..<Int(expectedTotal) {
            guard let part = asm.parts[UInt8(i)] else { return nil }
            merged.append(part)
        }

        // Cleanup for this packetId
        splitAssemblies.removeValue(forKey: packetId)

        return merged
    }

    private func printLog(_ message: String) {
        print("[\(self.address):\(self.port)] \(message)")
    }
}
