//
//  MinecraftResponse.swift
//  GameStatus
//
//  Created by Tom on 17/08/2025.
//

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

    // Description supports polymorphic decoding (String or Object)
    struct Description: Codable {
        let value: DescriptionObject

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                self.value = DescriptionObject(text: str, bold: nil, italic: nil, color: nil, obfuscated: nil, extra: nil)
            } else if let obj = try? container.decode(DescriptionObject.self) {
                self.value = obj
            } else {
                throw DecodingError.typeMismatch(DescriptionObject.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Description is neither String nor DescriptionObject"))
            }
        }
    }

    struct DescriptionObject: Codable {
        let text: String?
        let bold: Bool?
        let italic: Bool?
        let color: String?
        let obfuscated: Bool?
        let extra: [DescriptionObject]?

        func toPlainText() -> String {
            let base = text ?? ""
            if let extra = extra {
                return base + extra.map { $0.toPlainText() }.joined()
            }
            return base
        }
    }

    let version: MinecraftVersion
    let players: MinecraftPlayers
    //let description: Description
    let favicon: String?
}
