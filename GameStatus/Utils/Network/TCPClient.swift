//
//  TCPClient.swift
//  UDPClient
//
//  Created by Tom on 25/07/2025.
//

import Foundation
import Network

enum TCPResponseType {
    case status(String)
    case pong
}

final class TCPClient: @unchecked Sendable {
    private let connection: NWConnection
    private let address: String
    private let port: UInt16
    private var receiveBuffer = Data()
    private var bufferSize: Int = 0
    private var sentPingTimestamp: UInt64?
    private let queue = DispatchQueue(label: "TCPClientQueue")

    public var ping: UInt64?

    public var onReady: (() -> Void)?
    public var onFail: (() -> Void)?

    public var onResponse: ((TCPResponseType) -> Void)?
    public var onPingRTT: ((UInt64) -> Void)?

    init(host: String, port: UInt16) {
        self.address = host
        self.port = port

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        params.prohibitExpensivePaths = false
        params.prohibitConstrainedPaths = false

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.connectionTimeout = 10
        params.defaultProtocolStack.transportProtocol = tcpOptions

        self.connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port),
            using: params,
        )
    }

    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            printLog("Client state: \(state)")
            switch state {
            case .ready:
                self.queue.async {
                    self.onReady?()
                    self.sendHandshake()
                    self.receiveNext()
                }
            case .failed(let error):
                self.printLog("Client failed: \(error)")
                self.stop()
                self.onFail?()
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
            case .cancelled:
                printLog("Connection cancelled")
            default:
                break
            }
        }
        connection.start(queue: queue)
        printLog("Client Started")
    }

    func stop() {
        connection.cancel()
        printLog("Client Stopped")
    }

    func sendHandshake() {
        let handshakeData = self._formatHandshake()
        self.sentPingTimestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        connection.send(
            content: handshakeData,
            completion: .contentProcessed { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.printLog("Handshake send error: \(error)")
                    return
                }
                self.connection.send(
                    content: Data([0x01, 0x00]),
                    completion: .contentProcessed { error2 in
                        if let error2 = error2 {
                            self.printLog("Second send error: \(error2)")
                            return
                        }
                    }
                )
            }
        )
    }

    func receiveNext() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) {
            [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let error = error {
                printLog("Receive error: \(error)")
                return
            }
            guard let data = data else {
                printLog("No data received.")
                return
            }
            self.queue.async {
                self.handleReceivedData(data)
                if self.connection.state == .ready {
                    self.receiveNext()
                }
            }
        }
    }

    private func handleReceivedData(_ data: Data) {
        printLog("Received \(data.count) bytes")
        printLog(data.hexDescription)

        self.receiveBuffer.append(data)

        if self.bufferSize == 0 {
            var offset: Int = 0
            let _ = self.receiveBuffer.readVarInt(from: &offset)
            let _ = self.receiveBuffer.readVarInt(from: &offset)
            let jsonLength = self.receiveBuffer.readVarInt(from: &offset)
            self.bufferSize = jsonLength
            self.receiveBuffer.removeFirst(offset)
            printLog("Size is \(self.bufferSize) / offset is \(offset)")

            if self.ping == nil {
                if let sent = self.sentPingTimestamp {
                    let now = UInt64(Date().timeIntervalSince1970 * 1000)
                    self.ping = now - sent
                }
            }
        } else if self.receiveBuffer.count >= self.bufferSize {
            let jsonData = self.receiveBuffer.prefix(self.bufferSize)
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.onResponse?(.status(jsonStr))
                }
            }
            self.receiveBuffer.removeAll()
            self.bufferSize = 0
        }
    }

    private func _formatHandshake() -> Data {
        let protocolVersion: Int = 772
        let nextState: Int = 1

        var data: Data = Data([0x00])

        data.appendVarInt(protocolVersion)
        data.appendStringVarInt(self.address)
        data.append(UInt8(port >> 8))
        data.append(UInt8(port & 0xFF))
        data.appendVarInt(nextState)
        return Data().appendingPacket(with: data)
    }

    private func printLog(_ message: String) {
        print("[\(self.address):\(self.port)] \(message)")
    }
}
