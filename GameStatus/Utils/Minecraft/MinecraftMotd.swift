//
//  MinecraftMotd.swift
//  GameStatus
//
//  Created by Tom on 06/09/2025.
//

import SwiftUI

class MinecraftMotd {
    public static func renderString(_ str: String) -> AttributedString {
        var result = AttributedString()
        var currentColor: Color = .white
        var isBold = false
        var isItalic = false
        var isUnderlined = false
        var isStrikethrough = false

        var buffer = ""
        let chars = Array(str)
        var i = 0

        while i < chars.count {
            let c = chars[i]

            if c == "§", i + 1 < chars.count {
                // flush buffer
                if !buffer.isEmpty {
                    var part = AttributedString(buffer)
                    part.foregroundColor = currentColor
                    if isBold && isItalic {
                        part.font = .minecraft(.italicBold, size: 14)
                    } else if isBold {
                        part.font = .minecraft(.bold, size: 14)
                    } else if isItalic {
                        part.font = .minecraft(.italic, size: 14)
                    } else {
                        part.font = .minecraft(.basic, size: 14)
                    }
                    if isUnderlined { part.underlineStyle = .single }
                    if isStrikethrough { part.strikethroughStyle = .single }
                    result.append(part)
                    buffer = ""
                }

                let code = chars[i + 1]
                applyCode(
                    code,
                    currentColor: &currentColor,
                    isBold: &isBold,
                    isItalic: &isItalic,
                    isUnderlined: &isUnderlined,
                    isStrikethrough: &isStrikethrough
                )
                i += 2
                continue
            } else {
                buffer.append(c)
                i += 1
            }
        }

        // flush last part
        if !buffer.isEmpty {
            var part = AttributedString(buffer)
            part.foregroundColor = currentColor
            if isBold && isItalic {
                part.font = .minecraft(.italicBold, size: 14)
            } else if isBold {
                part.font = .minecraft(.bold, size: 14)
            } else if isItalic {
                part.font = .minecraft(.italic, size: 14)
            } else {
                part.font = .minecraft(.basic, size: 14)
            }
            if isUnderlined { part.underlineStyle = .single }
            if isStrikethrough { part.strikethroughStyle = .single }
            result.append(part)
        }

        return result
    }
    
    public static func renderDescriptionObject(
        _ desc: MinecraftPong.MinecraftDescription.DescriptionObject,
        inheritedBold: Bool = false,
        inheritedItalic: Bool = false,
        inheritedUnderline: Bool = false,
        inheritedStrikethrough: Bool = false
    ) -> AttributedString {
        var attrStr = AttributedString(desc.text ?? "")

        if let color = desc.color {
            attrStr.foregroundColor =
                color.isHexColor
                ? Color(hex: color)
                : Color(minecraftColorName: color)
        }

        let bold = desc.bold ?? inheritedBold
        let italic = desc.italic ?? inheritedItalic
        let underline = desc.underlined ?? inheritedUnderline
        let strikethrough = desc.strikethrough ?? inheritedStrikethrough

        if bold && italic {
            attrStr.font = .minecraft(.italicBold, size: 14)
        } else if bold {
            attrStr.font = .minecraft(.bold, size: 14)
        } else if italic {
            attrStr.font = .minecraft(.italic, size: 14)
        } else {
            attrStr.font = .minecraft(.basic, size: 14)
        }

        if underline {
            attrStr.underlineStyle = Text.LineStyle.single
        }
        if strikethrough {
            attrStr.strikethroughStyle = Text.LineStyle.single
        }

        for extra in desc.extra ?? [] {
            let childAttr: AttributedString
            switch extra {
            case .string(let str):
                var temp = AttributedString(str)

                if bold && italic {
                    temp.font = .system(.body).bold().italic()
                } else if bold {
                    temp.font = .system(.body).bold()
                } else if italic {
                    temp.font = .system(.body).italic()
                }
                if underline { temp.underlineStyle = Text.LineStyle.single }
                if strikethrough {
                    temp.strikethroughStyle = Text.LineStyle.single
                }
                childAttr = temp
            case .object(let obj):
                childAttr = renderDescriptionObject(
                    obj,
                    inheritedBold: bold,
                    inheritedItalic: italic,
                    inheritedUnderline: underline,
                    inheritedStrikethrough: strikethrough
                )
            }
            attrStr.append(childAttr)
        }
        return attrStr
    }

    private static func applyCode(
        _ code: Character,
        currentColor: inout Color,
        isBold: inout Bool,
        isItalic: inout Bool,
        isUnderlined: inout Bool,
        isStrikethrough: inout Bool
    ) {
        switch code {
        case "1": currentColor = Color(rgb: (0, 0, 170))
        case "2": currentColor = Color(rgb: (0, 170, 0))
        case "3": currentColor = Color(rgb: (0, 170, 170))
        case "4": currentColor = Color(rgb: (170, 0, 0))
        case "5": currentColor = Color(rgb: (170, 0, 170))
        case "6": currentColor = Color(rgb: (255, 170, 0))
        case "7": currentColor = Color(rgb: (170, 170, 170))
        case "8": currentColor = Color(rgb: (85, 85, 85))
        case "9": currentColor = Color(rgb: (85, 85, 255))
        case "a": currentColor = Color(rgb: (85, 255, 85))
        case "b": currentColor = Color(rgb: (85, 255, 255))
        case "c": currentColor = Color(rgb: (255, 85, 85))
        case "d": currentColor = Color(rgb: (255, 85, 255))
        case "e": currentColor = Color(rgb: (255, 255, 85))
        case "f": currentColor = Color(rgb: (255, 255, 255))

        case "l": isBold = true
        case "o": isItalic = true
        case "n": isUnderlined = true
        case "m": isStrikethrough = true

        case "r":
            currentColor = .white
            isBold = false
            isItalic = false
            isUnderlined = false
            isStrikethrough = false
        default: break
        }
    }
}
