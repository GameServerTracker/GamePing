//
//  MinecraftResponse.swift
//  GameStatus
//
//  Created by Tom on 17/08/2025.
//

import Foundation
import SwiftUI

struct MinecraftPong: Codable {
    struct MinecraftVersion: Codable {
        let name: String
        let `protocol`: Int
    }
    struct MinecraftPlayers: Codable {
        let max: Int
        let online: Int
        let sample: [MinecraftSample]?
    }
    struct MinecraftSample: Codable {
        let name: String
        let id: String
    }

    enum MinecraftDescription: Codable {
        case string(String)
        case object(DescriptionObject)

        struct DescriptionObject: Codable {
            let text: String?
            let color: String?
            let bold: Bool?
            let italic: Bool?
            let underlined: Bool?
            let strikethrough: Bool?
            let extra: [Extra]?

            enum Extra: Codable {
                case object(DescriptionObject)
                case string(String)

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let obj = try? container.decode(DescriptionObject.self) {
                        self = .object(obj)
                    } else if let str = try? container.decode(String.self) {
                        self = .string(str)
                    } else {
                        throw DecodingError.typeMismatch(
                            Extra.self,
                            DecodingError.Context(
                                codingPath: decoder.codingPath,
                                debugDescription:
                                    "Expected DescriptionObject or String in extra"
                            )
                        )
                    }
                }
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                self = .string(str)
            } else if let obj = try? container.decode(DescriptionObject.self) {
                self = .object(obj)
            } else {
                throw DecodingError.typeMismatch(
                    MinecraftDescription.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unexpected type for description"
                    )
                )
            }
        }
    }

    let version: MinecraftVersion
    let players: MinecraftPlayers
    let description: MinecraftDescription
    let favicon: String?
}

extension MinecraftPong.MinecraftDescription {
    func getAttributedString() -> AttributedString {
        switch self {
        case .string(let str):
            return MinecraftMotd.renderString(str)
        case .object(let obj):
            return MinecraftMotd.renderDescriptionObject(obj)
        }
    }
}
