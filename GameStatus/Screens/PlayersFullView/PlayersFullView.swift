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
    let players: [ServerPlayerInfo]
    
    var body: some View {
        ZStack {
            Color(.background)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(players) { playerRow in
                    PlayersFullRow(player: playerRow)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Players (\(players.count))")
        }
    }
}

struct PlayersFullRow: View {
    let player: ServerPlayerInfo
    @State private var showScore = false

    var body: some View {
        HStack {
            Image(systemName: (!player.name.isEmpty) ? "person.fill" : "person.wave.2.fill")
                .imageScale(.large)
            Text(!player.name.isEmpty ? player.name : "Trying to connect...")
                .font(.headline)
                .fontWeight(.medium)
                .textSelection(.enabled)
            if let score = player.score, let duration = player.duration {
                Spacer()
                Group {
                    if showScore {
                        scoreText(for: score)
                    } else {
                        durationText(for: duration)
                    }
                }
                .onTapGesture {
                    showScore.toggle()
                }
            } else if let duration = player.duration {
                Spacer()
                durationText(for: duration)
            } else if let score = player.score {
                Spacer()
                scoreText(for: score)
            } else if let ping = player.ping {
                Spacer()
                pingText(for: ping)
            }
        }
    }

    @ViewBuilder
    private func durationText(for duration: Int) -> some View {
        let date = Date(timeIntervalSinceNow: TimeInterval(duration) * -1)
        Text(date, format: .relative(presentation: .numeric, unitsStyle: .abbreviated))
            .font(.headline)
            .foregroundStyle(.secondary)
            .fontWeight(.regular)
    }
    
    @ViewBuilder
    private func scoreText(for score: Int) -> some View {
        Text("Score: \(score)")
            .font(.headline)
            .foregroundStyle(.secondary)
            .fontWeight(.regular)
    }
    
    @ViewBuilder
    private func pingText(for ping: Int) -> some View {
        Text("\(ping) ms")
            .font(.headline)
            .foregroundStyle(.secondary)
            .fontWeight(.regular)
    }
}

#Preview {
    PlayersFullView(players: [
        .init(name: "BliTz_37", score: 42, duration: 2048, ping: 42),
        .init(name: "Emperreur_Bonobo", score: 42, duration: 2048, ping: 42),
        .init(name: "TheFantasio974", score: 42, duration: 2048, ping: 42),
        .init(name: "batisseurr", score: 42, duration: 2048, ping: 42),
        .init(name: "tom_lafontaine", score: 42, duration: 8000, ping: 42),
        .init(name: "", score: 0, duration: 0, ping: 42),
     ])
}
