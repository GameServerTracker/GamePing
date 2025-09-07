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

    @Query private var gameServers: [GameServer]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showingConfirmationDelete: Bool = false
    @State private var showEditServerModal: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        if response?.favicon != nil {
                            ServerIconImage(base64Image: response?.favicon)
                                .frame(width: 102, height: 102)
                        } else {
                            ServerIconDefault(
                                iconImage: Image("serverLogo"),
                                gradientColors: [.brandPrimary],
                                iconSize: 52
                            ).frame(width: 102, height: 102)
                        }
                        VStack(alignment: .leading) {
                            Text(server.name)
                                .font(.title3)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            Text("\(server.address):\(String(server.port))")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .textSelection(.enabled)
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
                                           ? .statusOnline : .statusOffline)
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
                                        if response!.ping != nil {
                                            Text("\(response!.ping ?? 0) ms")
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
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                ServerDetailsScrollView(server: server, response: response)
                if response?.name != nil {
                    Text(response?.name ?? "N/A")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if response?.motd != nil {
                    VStack(alignment: .center, spacing: 8) {
                        Text(response?.motd ?? "N/A")
                    }
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark
                                  ? Color.white.opacity(0.15)
                                  : Color.black.opacity(0.6))
                    )
                    .frame(maxWidth: .infinity)
                }
                if let players = response?.players, !players.isEmpty {
                    NavigationLink {
                        PlayersFullView(players: players)
                    } label: {
                        PlayersListCard(players: players)
                    }
                    .buttonStyle(.plain)
                } else {
                    PlayersListCard(players: response?.players ?? [])
                }
                if (response?.keywords?.isEmpty) != nil {
                    NavigationLink {
                        TagsFullView(tags: (response?.keywords!)!)
                    } label: {
                        TagsListCard(tags: (response?.keywords!)!)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            UIPasteboard.general.string =
                                "\(server.address):\(String(server.port))"
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

                        Button {
                            showingConfirmationDelete = true
                        } label: {
                            Label("Delete Server", systemImage: "trash")
                                .foregroundStyle(Color.statusOffline)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this server ?",
                isPresented: $showingConfirmationDelete
            ) {
                Button("Delete", role: .destructive) {
                    do {
                        context.delete(server)
                        try context.save()
                        dismiss()
                    } catch {
                        print("Error during the deletion: \(error)")
                    }
                }
                Button("Cancel", role: .cancel) {
                    showingConfirmationDelete = false
                }
            }
            .sheet(isPresented: $showEditServerModal) {
                ServerFormView(server: server, isShowing: $showEditServerModal)
                    .presentationBackground(Color.background)
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
                if response?.playersMax != nil {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "MAX PLAYERS",
                        content: "\(response?.playersMax ?? 0)",
                        subtitle: nil
                    )
                }
                if response?.version != nil {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "VERSION",
                        content: (response?.version)!,
                        subtitle: nil
                    )
                }
                if response?.map != nil && response?.map != "" {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "MAP",
                        content: (response?.map)!,
                        subtitle: nil
                    )
                }
                if response?.game != nil {
                    Divider().frame(height: 55)
                    TextDetailsView(
                        title: "GAME",
                        content: (response?.game)!,
                        subtitle: nil
                    )
                }
                if response?.os != nil {
                    Divider().frame(height: 55)
                    ImageDetailsView(
                        title: "OS",
                        image: Image(
                            gameServerOsTypesIconName[response?.os ?? "U"]
                                ?? "questionmark.circle.fill"
                        ),
                        subtitle: gameServerOsTypesName[response?.os ?? "U"]
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
            if subtitle != nil {
                Text(subtitle!)
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
            if subtitle != nil {
                Text(subtitle!)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else {

            }
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameServer.self, configurations: config)

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
}
