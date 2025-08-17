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
    public var onResponse: ((TCPResponseType) -> Void)?
    public var onPingRTT: ((UInt64) -> Void)?
    
    init(host: String, port: UInt16) {
        self.address = host
        self.port = port
        self.connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port),
            using: .tcp
        )
    }
    
    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            print("Client state: \(state)")
            switch state {
            case .ready:
                self.queue.async {
                    self.onReady?()
                    self.sendHandshake()
                    self.receiveNext()
                }
            case .failed(let error):
                print("Connection failed with error: \(error)")
                self.stop()
            case .cancelled:
                print("Connection cancelled")
            default:
                break
            }
        }
        connection.start(queue: queue)
        print("Client Started")
    }
    
    func stop() {
        connection.cancel()
        print("Client Stopped")
    }
    
    func sendHandshake() {
        let handshakeData = self._formatHandshake()
        self.sentPingTimestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        connection.send(content: handshakeData, completion: .contentProcessed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Handshake send error: \(error)")
                return
            }
            self.connection.send(content: Data([0x01, 0x00]), completion: .contentProcessed { error2 in
                if let error2 = error2 {
                    print("Second send error: \(error2)")
                    return
                }
                //self.receiveNext()
            })
        })
    }
    
    func receiveNext() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let error = error {
                print("Receive error: \(error)")
                return
            }
            guard let data = data else {
                print("No data received.")
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
        print("📥 Received \(data.count) bytes")
        print(data.hexDescription)
        
        self.receiveBuffer.append(data)
        
        if self.bufferSize == 0 {
            var offset: Int = 0
            let _ = self.receiveBuffer.readVarInt(from: &offset)
            let _ = self.receiveBuffer.readVarInt(from: &offset)
            let jsonLength = self.receiveBuffer.readVarInt(from: &offset)
            self.bufferSize = jsonLength
            self.receiveBuffer.removeFirst(offset)
            print("Size is \(self.bufferSize) / offset is \(offset)")
            
            if (self.ping == nil) {
                if let sent = self.sentPingTimestamp {
                    let now = UInt64(Date().timeIntervalSince1970 * 1000)
                    self.ping = now - sent
                }
            }
        } else if self.receiveBuffer.count >= self.bufferSize {
            let jsonData = self.receiveBuffer.prefix(self.bufferSize)
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                //print("✅ JSON Response: \n\(jsonStr)")
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
}
