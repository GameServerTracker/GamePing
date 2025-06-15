//
//  ContentView.swift
//  GameStatus
//
//  Created by Tom on 10/05/2025.
//

import SwiftUI

struct ServerListView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                List(MockData.gameServers, id: \.id) { server in
                    NavigationLink {
                        ServerDetailsView(server: server)
                    } label: {
                        ServerListCell(server: server)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Servers")
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Spacer()
                    Button {
                        // Todo
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
        }
    }
}

#Preview {
    ServerListView()
}
