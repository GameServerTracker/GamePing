//
//  ServerIconDefault.swift
//  GameStatus
//
//  Created by Tom on 31/05/2025.
//

import SwiftUI

struct ServerIconDefault: View {
    
    let iconImage: Image
    let gradientColors: [Color]
    let iconSize: CGFloat
    let foregroundColor: Color

    init(iconImage: Image, gradientColors: [Color], iconSize: CGFloat = 24, foregroundColor: Color = .white) {
        self.iconImage = iconImage
        self.gradientColors = gradientColors
        self.iconSize = iconSize
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            .overlay(
                iconImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(foregroundColor)
                    .font(.system(size: iconSize))
            )
    }
}

#Preview {
    ServerIconDefault(iconImage: Image(systemName: "server.rack"), gradientColors: [.blue], iconSize: 64)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("minecraft_icon"), gradientColors: [.brown], iconSize: 92)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("steam_icon"), gradientColors: [.indigo], iconSize: 52)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("sourceengine_icon"), gradientColors: [.orange], iconSize: 82)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("fivem"), gradientColors: [.white], iconSize: 82)
        .frame(width: 128, height: 128)
}
