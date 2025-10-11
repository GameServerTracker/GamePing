//
//  ServerListCell.swift
//  GameStatus
//
//  Created by Tom on 11/05/2025.
//

import SwiftData
import SwiftUI

struct ServerListCell: View {
    let server: GameServer
    let response: ServerStatus?

    @Binding var selectedServer: GameServer?

    @Environment(\.modelContext) private var context

    var body: some View {
        HStack {
            HStack {
                HStack {
                    if response?.favicon != nil && !server.serverIconIgnore {
                        ServerIconImage(base64Image: response?.favicon)
                    } else {
                        ServerIconDefault(
                            iconImage: Image(server.iconName ?? "serverLogo"),
                            gradientColors: [(server.iconBgColor != nil) ? Color(hex: server.iconBgColor!) : .brandPrimary ],
                            foregroundColor: (server.iconBgColor != nil) ? Color(hex: server.iconFgColor!) : .white
                        )
                    }
                }.frame(width: 64, height: 64)
                VStack(alignment: .leading) {
                    Text(server.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    Text(gameServerTypesDisplayName[server.type]!)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }.padding(.leading, 10)
            }
            .frame(width: 210, alignment: .leading)
            VStack(alignment: .trailing) {
                if response != nil {
                    if response!.online {
                        HStack(spacing: 4) {
                            Image(
                                systemName: (response!.playersOnline! > 0
                                    ? "person.fill" : "person.slash.fill")
                            )
                            .foregroundStyle(
                                (response!.playersOnline! > 0
                                    ? .statusOnline : .gray)
                            )
                            .symbolRenderingMode(.hierarchical)
                            Text("\(response!.playersOnline ?? 0)")
                                .font(.callout)
                                .foregroundStyle(
                                    (response!.playersOnline! > 0
                                        ? .statusOnline : .gray)
                                )
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        if response!.ping != nil {
                            Text("\(response!.ping ?? 0) ms")
                                .font(.callout)
                                .lineLimit(1)
                        }
                    } else {
                        Text("Offline")
                            .font(.callout)
                            .foregroundStyle(.statusOffline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }

                } else {
                    ProgressView("Pinging...")
                        .font(.callout)
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .brandPrimary)
                        )
                }
            }.frame(width: 100, alignment: .trailing)
        }.swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                context.delete(server)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            Button {
                selectedServer = server
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }
    }
}

#Preview {
    ServerListCell(
        server: MockData.gameServers.first!,
        response: nil,
        selectedServer: .constant(nil)
    )
}
