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
    @Query(sort: [
        SortDescriptor(\GameServer.order, order: .forward),
        SortDescriptor(\GameServer.type, order: .forward),
        SortDescriptor(\GameServer.name, order: .forward),
    ])
    private var gameServers: [GameServer]

    @Environment(ServerStatusManager.self) var statusManager
    @Environment(\.modelContext) private var context

    @State private var viewModel: ServerListViewModel = .init()
    @State private var navigationSelectedServer: GameServer?
    @State private var draggedServer: GameServer?

    private var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        if isIPad {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPad

    private var iPadLayout: some View {
        NavigationStack {
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
                    iPadGrid
                }
            }
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if #available(iOS 26, *) {
                        Button {
                            viewModel.showAddServerModal = true
                            viewModel.selectedServer = nil
                        } label: {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            viewModel.showAddServerModal = true
                            viewModel.selectedServer = nil
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddServerModal) {
            ServerFormView(
                server: viewModel.selectedServer,
                isShowing: $viewModel.showAddServerModal
            ).presentationBackground(Color.background)
        }
    }

    // MARK: - iPad Grid (with drag & drop reordering)

    private var iPadGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 280, maximum: 340))
                ],
                spacing: 16
            ) {
                ForEach(gameServers, id: \.id) { server in
                    NavigationLink {
                        ServerDetailsView(
                            server: server,
                            response: statusManager.getResponse(
                                for: server
                            )
                        )
                    } label: {
                        ServerGridCard(
                            server: server,
                            response: statusManager.getResponse(
                                for: server
                            ),
                            selectedServer: $viewModel.selectedServer
                        )
                    }
                    .tint(.primary)
                    .draggable(server.id.uuidString) {
                        ServerGridCard(
                            server: server,
                            response: statusManager.getResponse(
                                for: server
                            ),
                            selectedServer: .constant(nil)
                        )
                        .frame(width: 280)
                        .opacity(0.8)
                        .onAppear { draggedServer = server }
                    }
                    .dropDestination(for: String.self) { _, _ in
                        draggedServer = nil
                        return false
                    } isTargeted: { isTargeted in
                        guard isTargeted,
                              let dragged = draggedServer,
                              dragged.id != server.id else { return }

                        withAnimation {
                            var servers = gameServers.sorted { $0.order < $1.order }
                            guard let fromIndex = servers.firstIndex(where: { $0.id == dragged.id }),
                                  let toIndex = servers.firstIndex(where: { $0.id == server.id })
                            else { return }

                            servers.move(
                                fromOffsets: IndexSet(integer: fromIndex),
                                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
                            )
                            for (index, item) in servers.enumerated() {
                                item.order = index
                            }
                            try? context.save()
                        }
                    }
                    .task {
                        if statusManager.getResponse(for: server)
                            == nil
                        {
                            await statusManager.fetchStatus(
                                for: server
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            statusManager.responses.removeAll()
            await statusManager.fetchAllStatuses(for: gameServers)
        }
    }

    // MARK: - iPhone

    private var iPhoneLayout: some View {
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
                    List {
                        ForEach(gameServers, id: \.id) { server in
                            NavigationLink {
                                ServerDetailsView(
                                    server: server,
                                    response: statusManager.getResponse(
                                        for: server
                                    )
                                )
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
                                if statusManager.getResponse(for: server) == nil
                                {
                                    await statusManager.fetchStatus(for: server)
                                }
                            }
                        }
                        .onMove(perform: { indices, newOffset in
                            var s = gameServers.sorted(by: {
                                $0.order < $1.order
                            })
                            s.move(fromOffsets: indices, toOffset: newOffset)
                            for (index, item) in s.enumerated() {
                                item.order = index
                            }
                            try? self.context.save()
                        })
                    }
                    .refreshable {
                        statusManager.responses.removeAll()
                        await statusManager.fetchAllStatuses(for: gameServers)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Servers")
            .overlay(alignment: .bottomTrailing) { fabButton }
        }
        .sheet(isPresented: $viewModel.showAddServerModal) {
            ServerFormView(
                server: viewModel.selectedServer,
                isShowing: $viewModel.showAddServerModal
            ).presentationBackground(Color.background)
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
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
                }.glassEffect(
                    .regular.tint(.brandPrimary),
                    in: Circle()
                )
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
}

#Preview {
    ServerListView()
        .modelContainer(for: GameServer.self, inMemory: true)
        .environment(ServerStatusManager())
}
