//
//  ServerListCell.swift
//  GameStatus
//
//  Created by Tom on 11/05/2025.
//

import SwiftUI

struct ServerListCell: View {
    let server: GameServer

    var body: some View {
        HStack {
            HStack {
                HStack {
                    if server.image != nil {
                        ServerIconImage(base64Image: server.image)
                    } else {
                        ServerIconDefault(iconImage: Image(systemName: "server.rack"),
                                          gradientColors: [.brandPrimary, .gray],
                                          iconSize: 32
                        )
                    }
                }.frame(width: 64, height: 64)
                VStack(alignment: .leading) {
                    Text(server.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    Text(server.type)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }.padding(.leading, 10)
            }
            .frame(width: 210, alignment: .leading)
            VStack(alignment: .trailing) {
                if server.response!.isQuerying {
                    ProgressView("Pinging...")
                        .font(.callout)
                        .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                    
                } else {
                    if server.response!.online {
                        HStack(spacing: 4) {
                            Image(systemName: (server.response!.player!.online > 0 ? "person.fill" : "person.slash.fill"))
                                .foregroundStyle((server.response!.player!.online > 0 ? .green : .gray))
                                .symbolRenderingMode(.hierarchical)
                            Text("\(server.response!.player?.online ?? 0)")
                                .font(.callout)
                                .foregroundStyle((server.response!.player!.online > 0 ? .green : .gray))
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        Text("\(server.response!.ping ?? 0) ms")
                            .font(.callout)
                            .lineLimit(1)
                    } else {
                        Text("Offline")
                            .font(.callout)
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                }
            }.frame(width: 110, alignment: .trailing)
        }
    }
}

#Preview {
    ServerListCell(server: MockData.gameServers.first!)
    ServerListCell(server: MockData.gameServers.last!)
}
