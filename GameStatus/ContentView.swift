//
//  ContentView.swift
//  GameStatus
//
//  Created by Tom on 10/05/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List(MockData.gameServers, id: \.id) { server in
                        ServerListCell(server: server)
                    }
                }.navigationTitle("Servers")
            }.safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .frame(width: 64, height: 64)
                            .foregroundColor(Color.white)
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
    ContentView()
}
