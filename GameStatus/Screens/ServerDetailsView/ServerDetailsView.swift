//
//  ServerDetailsView.swift
//  GameStatus
//
//  Created by Tom on 08/06/2025.
//

import SwiftData
import SwiftUI

struct ServerDetailsView: View {
    let server: GameServer
    let response: ServerStatus?
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(ServerStatusManager.self) var statusManager
    
    @State private var showEditServerModal: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        Button {
                            showEditServerModal = true
                        } label: {
                            if let favicon = response?.favicon, !server.serverIconIgnore {
                                ServerIconImage(base64Image: favicon)
                                    .frame(width: 102, height: 102)
                            } else {
                                ServerIconDefault(
                                    iconImage: Image(server.iconName ?? "serverLogo"),
                                    gradientColors: [(server.iconBgColor != nil) ? Color(hex: server.iconBgColor!) : .brandPrimary],
                                    foregroundColor: (server.iconBgColor != nil) ? Color(hex: server.iconFgColor!) : .white
                                ).frame(width: 102, height: 102)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(server.name)
                                .font(.title3)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            Text(server.getAddress())
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .textSelection(.enabled)
                            serverinfoCapsule
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                ServerDetailsScrollView(server: server, response: response)
                serverInfoContent
                Spacer()
            }
        }
        .refreshable {
            Task {
                if (response != nil) {
                    statusManager.responses.removeValue(forKey: server.id)
                    await statusManager.fetchStatus(for: server)
                }
            }
        }
        .background(Color.background)
        .toolbar { menuToolbarItems }
        .sheet(isPresented: $showEditServerModal) {
            ServerFormView(server: server, isShowing: $showEditServerModal)
                .presentationBackground(Color.background)
        }
    }
    
    @ViewBuilder
    private var serverinfoCapsule: some View {
        HStack(spacing: 10) {
            HStack {
                Text(
                    response == nil
                    ? "Pinging..."
                    : (response!.online
                       ? "Online" : "Offline")
                )
                .font(.caption)
                .fontWeight(.bold)
                .padding(8)
                .background(
                    response == nil
                    ? .brandPrimary
                    : (response!.online
                       ? .statusOnline
                       : .statusOffline)
                )
                .clipShape(Capsule())
                if response?.online == true {
                    Label(
                        "\(response?.playersOnline ?? 0)",
                        systemImage: "person.fill"
                    )
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(8)
                    .background(.statusOnline)
                    .clipShape(Capsule())
                    if let ping = response?.ping {
                        Text("\(ping) ms")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(.statusOnline)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var serverInfoContent: some View {
        if let name = response?.name {
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .textSelection(.enabled)
        }
        if let motd = response?.motd {
            MotdCard(motd: motd)
        }
        if let players = response?.players, !players.isEmpty {
            NavigationLink {
                PlayersFullView(players: players)
            } label: {
                PlayersListCard(players: response?.players?.map(\.name) ?? [])
            }
            .buttonStyle(.plain)
        } else {
            PlayersListCard(players: [])
        }
        if let keywords = response?.keywords, !keywords.isEmpty {
            NavigationLink {
                TagsFullView(tags: keywords)
            } label: {
                TagsListCard(tags: keywords)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ToolbarContentBuilder
    private var menuToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    UIPasteboard.general.string = server.getAddress()
                } label: {
                    Label(
                        "Copy Address",
                        systemImage: "doc.on.clipboard"
                    )
                }

                Button {
                    showEditServerModal = true
                } label: {
                    Label("Edit Server", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    do {
                        context.delete(server)
                        try context.save()
                        dismiss()
                    } catch {
                        print("Error during the deletion: \(error)")
                    }
                } label: {
                    Label("Delete Server", systemImage: "trash")
                }
            } label: {
                if #available(iOS 26, *) {
                    Image(systemName: "ellipsis")
                } else {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct ServerDetailsScrollView: View {
    let server: GameServer
    let response: ServerStatus?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ImageDetailsView(
                    title: "TYPE",
                    image: Image(
                        gameServerTypesIconName[server.type]
                            ?? "questionmark.circle.fill"
                    ),
                    subtitle: gameServerTypesDisplayName[server.type]
                        ?? "Unknown"
                )
                if let playerMax = response?.playersMax {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "MAX PLAYERS",
                        content: "\(playerMax)",
                        subtitle: nil
                    )
                }
                if let version = response?.version {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "VERSION",
                        content: version,
                        subtitle: nil
                    )
                }
                if let map = response?.map, map != "" {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "MAP",
                        content: map,
                        subtitle: nil
                    )
                }
                if let game = response?.game {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "GAME",
                        content: game,
                        subtitle: nil
                    )
                }
                if let os = response?.os {
                    Divider().frame(height: 55)
                    ImageDetailsView(
                        title: "OS",
                        image: Image(
                            gameServerOsTypesIconName[os]
                                ?? "questionmark.circle.fill"
                        ),
                        subtitle: gameServerOsTypesName[os]
                            ?? "Unknown"
                    )
                }
            }.frame(height: 90)
                .overlay(Divider(), alignment: .top)
                .padding(.horizontal)

        }
        .overlay(Divider(), alignment: .top)
        .padding(.top, 10)
    }
}

struct ImageDetailsView: View {
    let title: String
    let image: Image
    let subtitle: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(title.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
                .fontWeight(.bold)
            image
                .resizable()
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }.frame(maxWidth: .infinity)
    }
}

struct TextDetailsView: View {
    let title: String
    let content: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(title.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
                .fontWeight(.bold)
            VStack {
                Text(content)
                    .foregroundStyle(.secondary)
                    .fontWeight(.bold)
                    .font(.callout)
            }
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: GameServer.self,
        configurations: config
    )

    return ServerDetailsView(
        server: MockData.gameServers.last!,
        response: .init(
            online: true,
            playersOnline: 99999,
            playersMax: 99999,
            players: nil,
            name: "DEBUG",
            game: "DebugWars",
            motd: nil,
            map: "de_dust2",
            version: "1.12.2",
            ping: 999,
            favicon: nil,
            os: "l",
            keywords: ["tagAlpha", "tagBeta", "tagDev", "tagTest"]
        )
    )
    .modelContainer(container)
    .environment(ServerStatusManager())
}
