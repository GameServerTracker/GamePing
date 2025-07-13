//
//  ServerDetailsView.swift
//  GameStatus
//
//  Created by Tom on 08/06/2025.
//

import SwiftUI
import SwiftData

struct ServerDetailsView: View {
    let server: GameServer
    let response: GameServerResponse?
    
    @Query private var gameServers: [GameServer]
    @Environment(\.modelContext) private var context;
    @Environment(\.dismiss) private var dismiss;

    @State private var showingConfirmationDelete: Bool = false
    @State private var showEditServerModal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    if response?.favicon != nil {
                        ServerIconImage(base64Image: response?.favicon)
                            .frame(width: 102, height: 102)
                    } else {
                        ServerIconDefault(iconImage: Image("serverLogo"),
                                          gradientColors: [.brandPrimary],
                                          iconSize: 52
                        ).frame(width: 102, height: 102)
                    }
                    VStack(alignment: .leading) {
                        Text(server.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        Text(server.address)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        HStack (spacing: 10) {
                            HStack {
                                Text(
                                    response == nil ? "Pinging..." :
                                    (response!.online ? "Online" : "Offline")
                                )
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(
                                        response == nil ? .brandPrimary :
                                        (response!.online ? .statusOnline : .statusOffline)
                                    )
                                    .clipShape(Capsule())
                                if (response?.online == true) {
                                    Label("\(response?.players?.online ?? 0)", systemImage: "person.fill")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(8)
                                        .background(.statusOnline)
                                        .clipShape(Capsule())
                                    Text("\(response!.ping ?? 0) ms")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(8)
                                        .background(.statusOnline)
                                        .clipShape(Capsule())
                                }
                            }
                            ShareLink(item: "\(server.name)\n\(server.address)") {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.brandPrimary)
                            }
                        }
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (alignment: .top) {
                    ImageDetailsView(title: "TYPE", image: Image(gameServerTypesIconName[server.type] ?? "questionmark.circle.fill"), subtitle: gameServerTypesDisplayName[server.type] ?? "Unknown")
                    Divider().frame(height: 55)
                    TextDetailsView(title: "MAX PLAYERS", content: "\(response?.players?.online ?? 0)", subtitle: nil)
                    Divider().frame(height: 55)
                    TextDetailsView(title: "VERSION", content: "2025.03.26", subtitle: nil)
                    if (response?.map != nil) {
                        Divider().frame(height: 55)
                        TextDetailsView(title: "MAP", content: "rp_rockford_v2b", subtitle: nil)
                    }
                    if (response?.OS != nil) {
                        Divider().frame(height: 55)
                        ImageDetailsView(title: "OS", image: Image("linux_icon"), subtitle: "Linux")
                    }
                }.frame(height: 90)
                    .overlay(Divider(), alignment: .top)
                    .padding(.horizontal)
                
            }.overlay(Divider(), alignment: .top)
                .padding(.top, 10)
            VStack(alignment: .trailing) {
                Text("Players")
                    .font(.title)
                    .fontWeight(.bold)
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<20) {
                            Text("Item \($0)")
                                .font(.title)
                        }
                    }
                }
            }.padding(15)
            Spacer()
        }.background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingConfirmationDelete = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.statusOffline)
                    }
                    .confirmationDialog("Are you sure you want to delete this server?", isPresented: $showingConfirmationDelete) {
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
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditServerModal = true
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                }
            }
            .sheet(isPresented: $showEditServerModal) {
                ServerFormView(server: server, isShowing: $showEditServerModal).presentationBackground(Color.background)
            }
    }
}

struct ImageDetailsView: View {
    let title: String
    let image: Image
    let subtitle: String?
    
    var body: some View {
        VStack (alignment: .center) {
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
        VStack (alignment: .center) {
            Text(title.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
                .fontWeight(.bold)
            VStack() {
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
    ServerDetailsView(server: MockData.gameServers.last!, response: nil)
        .modelContainer(for: GameServer.self, inMemory: true)
}
