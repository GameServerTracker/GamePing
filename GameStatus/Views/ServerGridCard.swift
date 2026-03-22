//
//  ServerGridCard.swift
//  GameStatus
//
//  Created by Tom on 21/03/2026.
//

import SwiftData
import SwiftUI

private struct LiquidGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
        } else {
            content
        }
    }
}

struct ServerGridCard: View {
    let server: GameServer
    let response: ServerStatus?

    @Binding var selectedServer: GameServer?

    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Group {
                    if let favicon = response?.favicon, !server.serverIconIgnore {
                        ServerIconImage(base64Image: favicon)
                    } else {
                        ServerIconDefault(
                            iconImage: Image(server.iconName ?? "serverLogo"),
                            gradientColors: [(server.iconBgColor != nil) ? Color(hex: server.iconBgColor!) : .brandPrimary],
                            foregroundColor: (server.iconBgColor != nil) ? Color(hex: server.iconFgColor!) : .white
                        )
                    }
                }
                .frame(width: 64, height: 64)

                Spacer()

                statusView
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(server.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(gameServerTypesDisplayName[server.type] ?? server.type)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .background {
            if #available(iOS 26, *) {
                Color.clear
            } else {
                Color(.secondarySystemGroupedBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .modifier(LiquidGlassCardModifier())
        .contextMenu {
            Button {
                selectedServer = server
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                context.delete(server)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if let response = response {
            if response.online {
                VStack(alignment: .trailing, spacing: 2) {
                    if let playersOnline = response.playersOnline {
                        HStack(spacing: 3) {
                            Image(systemName: playersOnline > 0 ? "person.fill" : "person.slash.fill")
                                .foregroundStyle(playersOnline > 0 ? .statusOnline : .gray)
                                .symbolRenderingMode(.hierarchical)
                                .font(.headline)
                            Text("\(playersOnline)")
                                .font(.headline)
                                .foregroundStyle(playersOnline > 0 ? .statusOnline : .gray)
                                .fontWeight(.medium)
                        }
                    } else {
                        Text("Online")
                            .font(.headline)
                            .foregroundStyle(.statusOnline)
                            .fontWeight(.medium)
                    }
                    if let ping = response.ping {
                        Text("\(ping) ms")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Offline")
                    .font(.caption)
                    .foregroundStyle(.statusOffline)
                    .fontWeight(.medium)
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                .scaleEffect(0.8)
        }
    }
}
