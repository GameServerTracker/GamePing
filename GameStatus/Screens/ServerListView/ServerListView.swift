//
//  ContentView.swift
//  GameStatus
//
//  Created by Tom on 10/05/2025.
//

import SwiftData
import SwiftUI

var isPreview: Bool =
    (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1")

struct ServerListView: View {
    @Query(sort: [SortDescriptor(\GameServer.type, order: .forward), SortDescriptor(\GameServer.name, order: .forward)])
    private var gameServers: [GameServer]

    @EnvironmentObject var statusManager: ServerStatusManager
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: ServerListViewModel = .init()

    var body: some View {
        NavigationView {
            ZStack {
                if gameServers.isEmpty {
                    EmptyState(
                        title:
                            "No servers added\n Click the plus button to add one",
                        imageName: "serverLogoUnique"
                    )
                } else {
                    Color(.background)
                        .edgesIgnoringSafeArea(.all)
                    List(gameServers, id: \.id) { server in
                        NavigationLink {
                            ServerDetailsView(server: server, response: statusManager.getResponse(for: server))
                        } label: {
                            ServerListCell(
                                server: server,
                                response: statusManager.getResponse(
                                    for: server
                                ),
                                selectedServer: $viewModel.selectedServer
                            )
                        }
                        .listRowBackground(Color.clear)
                        .task {
                            if statusManager.getResponse(for: server) == nil {
                                await statusManager.fetchStatus(for: server)
                            }
                        }
                    }.refreshable {
                        statusManager.responses.removeAll()
                        await statusManager.fetchAllStatuses(for: gameServers)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    
                }
            }
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    if isPreview {
                        Button {
                            let newServer = GameServer(
                                name: "Test",
                                address: "202.181.188.156",
                                port: 27016,
                                type: .source,
                                image: nil
                            )
                            context.insert(newServer)
                        } label: {
                            Image(systemName: "hammer")
                                .imageScale(.large)
                                .frame(width: 42, height: 42)
                                .foregroundColor(.white)
                                .background(Color.brandPrimary)
                                .clipShape(Circle())
                                .shadow(radius: 2.5)
                        }.padding(.horizontal)
                    }
                    Spacer()
                    
                    if #available(iOS 26, *) {
                        Button {
                            viewModel.showAddServerModal = true
                            viewModel.selectedServer = nil
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                        }.glassEffect(.regular.tint(.brandPrimary), in: Circle())
                        .padding(.vertical).padding()
                    } else {
                        Button {
                            viewModel.showAddServerModal = true
                            viewModel.selectedServer = nil
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                                .background(Color.brandPrimary)
                                .clipShape(Circle())
                                .shadow(radius: 2.5)
                        }.padding(.vertical).padding(.horizontal)
                    }
                }
            }
        }.sheet(isPresented: $viewModel.showAddServerModal) {
            ServerFormView(
                server: viewModel.selectedServer,
                isShowing: $viewModel.showAddServerModal
            ).presentationBackground(Color.background)
        }
    }
}

#Preview {
    ServerListView()
        .modelContainer(for: GameServer.self, inMemory: true)
        .environmentObject(ServerStatusManager())
}
