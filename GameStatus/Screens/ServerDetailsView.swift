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
    
    @Query private var gameServers: [GameServer]
    @Environment(\.modelContext) private var context;
    @Environment(\.dismiss) private var dismiss;
    @State private var showingConfirmationDelete = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    if server.image != nil {
                        ServerIconImage(base64Image: server.image)
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
                                Text("Online")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(.statusOnline)
                                    .clipShape(Capsule())
                                Label("123", systemImage: "person.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(.statusOnline)
                                    .clipShape(Capsule())
                                Text("128ms")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(.statusOnline)
                                    .clipShape(Capsule())
                            }
                            Button {
                                
                            } label: {
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
                    ImageDetailsView(title: "TYPE", image: Image("minecraft_icon"), subtitle: "Minecraft")
                    Divider().frame(height: 55)
                    TextDetailsView(title: "MAX PLAYERS", content: "10 000", subtitle: "Players")
                    Divider().frame(height: 55)
                    TextDetailsView(title: "VERSION", content: "2025.03.26", subtitle: nil)
                    Divider().frame(height: 55)
                    TextDetailsView(title: "Map", content: "rp_rockford_v2b  ", subtitle: nil)
                    Divider().frame(height: 55)
                    ImageDetailsView(title: "OS", image: Image("linux_icon"), subtitle: "Linux")
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
                                // Gérer l'erreur (optionnel)
                                print("Erreur lors de la suppression du serveur : \(error)")
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            showingConfirmationDelete = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                }
            }
    }
}

#Preview {
    ServerDetailsView(server: MockData.gameServers.last!)
        .modelContainer(for: GameServer.self, inMemory: true)
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
