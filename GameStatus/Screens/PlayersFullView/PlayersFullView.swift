//
//  PlayersFullView.swift
//  GameStatus
//
//  Created by Tom on 16/08/2025.
//

import SwiftUI

struct PlayerRow: Identifiable {
    let id = UUID()
    let name: String
}

struct PlayersFullView: View {
    let players: [String]
    
    var body: some View {
        ZStack {
            Color(.background)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(players.map { PlayerRow(name: $0) }) { playerRow in
                    PlayersFullRow(player: playerRow.name)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Players (\(players.count))")
        }
    }
}

struct PlayersFullRow: View {
    let player: String

    var body: some View {
        HStack {
            Image(systemName: (!player.isEmpty) ? "person.fill" : "person.wave.2.fill")
                .imageScale(.large)
            Text(!player.isEmpty ? player : "Trying to connect...")
                .font(.headline)
                .fontWeight(.medium)
//            Spacer()
//            Text("5h")
//                .font(.body)
//                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PlayersFullView(players: [
        "BliTz_37", "Emperreur_Bonobo", "TheFantasio974", "batissdeurr",
         "Emperreur_Bonobo7", "Emperreur_Bonobo6", "Emperreur_Bonobo5",
         "Emperreur_Bonobo3", "tom_lafontaine", ""
     ])
}
