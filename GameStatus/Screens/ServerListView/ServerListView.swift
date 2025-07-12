//
//  ContentView.swift
//  GameStatus
//
//  Created by Tom on 10/05/2025.
//

import SwiftUI
import SwiftData

var isPreview: Bool = (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1")

struct ServerListView: View {
    @Query private var gameServers: [GameServer]
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: ServerListViewModel = .init()

    var body: some View {
        NavigationView {
            ZStack {
                if (gameServers.isEmpty) {
                    EmptyState(title: "No servers added\n Click the plus button to add one", imageName: "serverLogoUnique")
                } else {
                        Color(.background)
                            .edgesIgnoringSafeArea(.all)
                        List(gameServers, id: \.id) { server in
                            NavigationLink {
                                ServerDetailsView(server: server)
                            } label: {
                                ServerListCell(server: server)
                            }
                            .listRowBackground(Color.clear)
                        }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Servers")
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    if (isPreview) {
                        Button {
                            let newServer = GameServer(name: "Test", address: "192.168.1.1", port: 80, type: .minecraft, image: nil)
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
                    Button {
                        viewModel.showAddServerModal = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .frame(width: 64, height: 64)
                            .foregroundColor(.white)
                            .background(Color.brandPrimary)
                            .clipShape(Circle())
                            .shadow(radius: 2.5)
                    }.padding(.horizontal)
                }
            }
        }.sheet(isPresented: $viewModel.showAddServerModal) {
            ServerFormView(server: nil, isShowing: $viewModel.showAddServerModal).presentationBackground(Color.background)
        }
    }
}

#Preview {
    ServerListView()
        .modelContainer(for: GameServer.self, inMemory: true)
}
