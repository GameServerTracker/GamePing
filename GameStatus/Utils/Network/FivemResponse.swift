//
//  FivemResponse.swift
//  GameStatus
//
//  Created by Tom on 18/08/2025.
//

import Foundation

struct FivemInfoResponse: Codable {
    let enhancedHostSupport: Bool?
    let icon: String?
    let requestSteamTicket: String?
    let resources: [String]?
    let server: String?
    let vars: Vars?
    let version: Int?
    
    struct Vars: Codable {
        let disableClientReplays: Bool?
        let enforceGameBuild: Int?
        let enhancedHostSupport: Bool?
        let lan: Bool?
        let licenseKeyToken: String?
        let maxClients: Int?
        let poolSizesIncrease: String?
        let projectDesc: String?
        let projectName: String?
        let pureLevel: Int?
        let replaceExeToSwitchBuilds: Bool?
        let scriptHookAllowed: Bool?
        let tags: String?
        
        enum CodingKeys: String, CodingKey {
            case disableClientReplays = "sv_disableClientReplays"
            case enforceGameBuild = "sv_enforceGameBuild"
            case enhancedHostSupport = "sv_enhancedHostSupport"
            case lan = "sv_lan"
            case licenseKeyToken = "sv_licenseKeyToken"
            case maxClients = "sv_maxClients"
            case poolSizesIncrease = "sv_poolSizesIncrease"
            case projectDesc = "sv_projectDesc"
            case projectName = "sv_projectName"
            case pureLevel = "sv_pureLevel"
            case replaceExeToSwitchBuilds = "sv_replaceExeToSwitchBuilds"
            case scriptHookAllowed = "sv_scriptHookAllowed"
            case tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            disableClientReplays = try container.decodeStringAsBool(forKey: .disableClientReplays)
            enforceGameBuild = try container.decodeStringAsInt(forKey: .enforceGameBuild)
            enhancedHostSupport = try container.decodeStringAsBool(forKey: .enhancedHostSupport)
            lan = try container.decodeStringAsBool(forKey: .lan)
            licenseKeyToken = try container.decodeIfPresent(String.self, forKey: .licenseKeyToken)
            maxClients = try container.decodeStringAsInt(forKey: .maxClients)
            poolSizesIncrease = try container.decodeIfPresent(String.self, forKey: .poolSizesIncrease)
            projectDesc = try container.decodeIfPresent(String.self, forKey: .projectDesc)
            projectName = try container.decodeIfPresent(String.self, forKey: .projectName)
            pureLevel = try container.decodeStringAsInt(forKey: .pureLevel)
            replaceExeToSwitchBuilds = try container.decodeStringAsBool(forKey: .replaceExeToSwitchBuilds)
            scriptHookAllowed = try container.decodeStringAsBool(forKey: .scriptHookAllowed)
            tags = try container.decodeIfPresent(String.self, forKey: .tags)
        }
    }
}

struct FivemDynamicResponse: Codable {
    let clients: Int?
    let gametype: String?
    let hostname: String?
    let iv: String?
    let mapname: String?
    let maxclients: Int?
    
    enum CodingKeys: String, CodingKey {
        case clients
        case gametype
        case hostname
        case iv
        case mapname
        case maxclients = "sv_maxclients"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        clients = try container.decodeStringAsInt(forKey: .clients)
        gametype = try container.decodeIfPresent(String.self, forKey: .gametype)
        hostname = try container.decodeIfPresent(String.self, forKey: .hostname)
        iv = try container.decodeIfPresent(String.self, forKey: .iv)
        mapname = try container.decodeIfPresent(String.self, forKey: .mapname)
        maxclients = try container.decodeStringAsInt(forKey: .maxclients)
    }
}

struct FivemPlayersResponse: Codable {
    let players: [FivemPlayer]?
}

struct FivemPlayer: Codable {
    let endpoint: String
    let id: Int
    let identifiers: [String]
    let name: String
    let ping: Int
}

private extension KeyedDecodingContainer {
    func decodeStringAsBool(forKey key: Key) throws -> Bool? {
        if let bool = try? decodeIfPresent(Bool.self, forKey: key) {
            return bool
        }
        if let string = try? decodeIfPresent(String.self, forKey: key) {
            return (string as NSString).boolValue
        }
        return nil
    }
    
    func decodeStringAsInt(forKey key: Key) throws -> Int? {
        if let int = try? decodeIfPresent(Int.self, forKey: key) {
            return int
        }
        if let string = try? decodeIfPresent(String.self, forKey: key),
           let int = Int(string) {
            return int
        }
        return nil
    }
}
