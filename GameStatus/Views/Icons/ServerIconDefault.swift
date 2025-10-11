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
    let foregroundColor: Color

    private let fillRatio: CGFloat = 0.68

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let corner = side * 0.22
            let iconSide = side * fillRatio

            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                iconImage
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    .frame(width: iconSide, height: iconSide)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ServerIconDefault(iconImage: Image(systemName: "server.rack"), gradientColors: [.blue], foregroundColor: .white)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("minecraft_icon"), gradientColors: [.brown], foregroundColor: .white)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("steam_icon"), gradientColors: [.indigo], foregroundColor: .white)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("sourceengine_icon"), gradientColors: [.orange], foregroundColor: .white)
        .frame(width: 128, height: 128)
    ServerIconDefault(iconImage: Image("fivem"), gradientColors: [.white], foregroundColor: .white)
        .frame(width: 128, height: 128)
}
