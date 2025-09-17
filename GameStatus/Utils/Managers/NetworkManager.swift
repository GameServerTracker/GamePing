//
//  NetworkManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation

final class NetworkManager {
    static let baseURL = "https://api.gameservertracker.io"

    static func fetchFiveMInfo(address: String, port: Int) async -> FivemInfoResponse? {
        let url = URL(string: "\(Self.baseURL)/fivem/info/\(address):\(port)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let str = String(data: data, encoding: .utf8),
                str.trimmingCharacters(in: .whitespacesAndNewlines) == "Nope" {
                 return nil
             }
        
            let decoded = try JSONDecoder().decode(FivemInfoResponse.self, from: data)
            return decoded
        } catch {
            print("[\(#fileID):\(#line)] \(#function) failed: \(error)")
            return nil
        }
    }
    
    static func fetchFiveMDynamic(address: String, port: Int) async -> FiveMServerResponse? {
        let url = URL(string: "\(Self.baseURL)/fivem/\(address):\(port)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let str = String(data: data, encoding: .utf8),
                str.trimmingCharacters(in: .whitespacesAndNewlines) == "Nope" {
                 return nil
             }
        
            let decoded = try JSONDecoder().decode(FiveMServerResponse.self, from: data)
            return decoded
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("[\(#fileID):\(#line)] \(#function) Request cancelled")
                return nil
            }
            print("[\(#fileID):\(#line)] \(#function) failed: \(error)")
            return nil
        }
    }
    
    static func fetchFiveMPlayers(address: String, port: Int) async -> [FivemPlayer]? {
        let url = URL(string: "\(Self.baseURL)/fivem/players/\(address):\(port)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let str = String(data: data, encoding: .utf8),
                str.trimmingCharacters(in: .whitespacesAndNewlines) == "Nope" {
                 return nil
             }
        
            let decoded = try JSONDecoder().decode(FivemPlayersResponse.self, from: data)
            return decoded.players ?? []
        } catch {
            print("[\(#fileID):\(#line)] \(#function) failed: \(error)")
            return nil
        }
    }
}
