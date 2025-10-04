//
//  Color+ext.swift
//  GameStatus
//
//  Created by Tom on 06/09/2025.
//

import SwiftUI

extension Color {
    
    var hex: String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#FFFFFFFF"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(rgb: (Int, Int, Int)) {
        self.init(
            red: Double(rgb.0) / 255.0,
            green: Double(rgb.1) / 255.0,
            blue: Double(rgb.2) / 255.0
        )
    }

    init(minecraftColorName: String) { 
        switch minecraftColorName {
        case "black":
            self.init(.black)
            break
        case "dark_blue":
            self.init(rgb: (0, 0, 170))
            return
        case "dark_green":
            self.init(rgb: (0, 170, 0))
            return
        case "dark_aqua":
            self.init(rgb: (0, 170, 170))
            return
        case "dark_red":
            self.init(rgb: (170, 0, 0))
            return
        case "dark_purple":
            self.init(rgb: (170, 0, 170))
            return
        case "gold":
            self.init(rgb: (255, 170, 0))
        case "gray":
            self.init(rgb: (170, 170, 170))
            return
        case "dark_gray":
            self.init(rgb: (85, 85, 85))
            break
        case "blue":
            self.init(rgb: (85, 85, 255))
            return
        case "green":
            self.init(rgb: (85, 255, 85))
            return
        case "aqua":
            self.init(rgb: (85, 255, 255))
            return
        case "red":
            self.init(rgb: (255, 85, 85))
            break
        case "light_purple":
            self.init(rgb: (255, 85, 255))
        case "yellow":
            self.init(rgb: (255, 255, 85))
            break
        case "white":
            self.init(rgb: (255, 255, 255))
        case "minecoin_gold":
            self.init(rgb: (221, 214, 5))
        case "material_quartz":
            self.init(rgb: (227, 212, 209))
        case "material_iron":
            self.init(rgb: (206, 202, 202))
        case "material_netherite":
            self.init(rgb: (68, 58, 59))
        case "material_redstone":
            self.init(rgb: (151, 22, 7))
        case "material_copper":
            self.init(rgb: (180, 104, 77))
        case "material_gold":
            self.init(rgb: (222, 177, 45))
        case "material_emerald":
            self.init(rgb: (17, 160, 54))
        case "material_diamond":
            self.init(rgb: (44, 186, 168))
        case "material_lapis":
            self.init(rgb: (33, 73, 123))
        case "material_amethyst":
            self.init(rgb: (154, 92, 198))
        default:
            self.init(.white)
        }
    }
}
