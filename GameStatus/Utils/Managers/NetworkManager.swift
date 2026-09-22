//
//  NetworkManager.swift
//  GameStatus
//
//  Created by Tom on 13/07/2025.
//

import Foundation
import UIKit

final class NetworkManager {
    static let fivemBaseURL = "https://frontend.cfx-services.net/api/servers"

    static func fetchFiveMInfo(address: String, port: Int) async -> FivemInfoResponse? {
        await fetchFiveMJSON(address: address, port: port, path: "/info.json")
    }

    static func fetchFiveMDynamic(address: String, port: Int) async -> FivemDynamicResponse? {
        await fetchFiveMJSON(address: address, port: port, path: "/dynamic.json")
    }

    static func fetchFiveMPlayers(address: String, port: Int) async -> [FivemPlayer]? {
        await fetchFiveMJSON(address: address, port: port, path: "/players.json")
    }

    /// Queries a FiveM server's HTTP endpoint directly. The address is user input,
    /// so the URL is built with URLComponents (handles IPv6, rejects invalid hosts).
    private static func fetchFiveMJSON<T: Decodable>(
        address: String,
        port: Int,
        path: String
    ) async -> T? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = address
        components.port = port
        components.path = path
        guard let url = components.url else {
            print("[\(#fileID):\(#line)] \(#function) invalid URL for \(address):\(port)\(path)")
            return nil
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 2

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            if let str = String(data: data, encoding: .utf8),
                str.trimmingCharacters(in: .whitespacesAndNewlines) == "Nope" {
                 return nil
             }

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("[\(#fileID):\(#line)] \(#function) Request cancelled")
                return nil
            }
            print("[\(#fileID):\(#line)] \(#function) \(path) failed: \(error)")
            return nil
        }
    }

    static func fetchFiveMCfx(code: String) async -> FivemCfxResponse? {
        let url = URL(string: "\(Self.fivemBaseURL)/single/\(code)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(FivemCfxResponse.self, from: data)
            return decoded
        } catch {
            print("[\(#fileID):\(#line)] \(#function) failed: \(error)")
            return nil
        }
    }

    static func getFivemFavicons(code: String, version: Int) async -> String? {
        let url = URL(string: "\(Self.fivemBaseURL)/icon/\(code)/\(version).png")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 2

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard UIImage(data: data) != nil else { return nil }
            return data.base64EncodedString()
        } catch {
            print("[\(#fileID):\(#line)] \(#function) failed: \(error)")
            return nil
        }
    }
}
