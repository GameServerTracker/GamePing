//
//  Font+ext.swift
//  GameStatus
//
//  Created by Tom on 06/09/2025.
//

import SwiftUI

enum MinecraftFontStyle {
    case basic
    case bold
    case italic
    case italicBold
    
    var fontName: String {
        switch self {
        case .basic: return "Minecraft-Regular"
        case .bold: return "Minecraft-Bold"
        case .italic: return "Minecraft-Italic"
        case .italicBold: return "Minecraft-BoldItalic"
        }
    }
}

extension Font {
    static func minecraft(_ style: MinecraftFontStyle, size: CGFloat = 14) -> Font {
        return .custom(style.fontName, size: size)
    }
}
