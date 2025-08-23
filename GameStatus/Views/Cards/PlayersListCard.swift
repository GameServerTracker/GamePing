//
//  PlayersListCard.swift
//  GameStatus
//
//  Created by Tom on 16/07/2025.
//

import SwiftUI

struct PlayersListCard: View {

    private let fixedColumn = [

        GridItem(.fixed(160)),
        GridItem(.fixed(160)),
    ]
    
    private let playerCardLimit: Int = 9

    let players: [String]

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                Label("Players", systemImage: "person.3.fill")
                    .font(.headline)
                Spacer()
                if !players.isEmpty {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.brandPrimary)
                }
            }
            if players.isEmpty {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .resizable()
                    .scaledToFit()
                    .imageScale(.large)
                    .frame(width: 52, height: 52)
                    .foregroundColor(.blue)
                Text("No Players available")
                    .font(.title3)
                    .fontWeight(.semibold)
            } else {
                ZStack {
                    LazyVGrid(columns: fixedColumn, spacing: 10) {
                        ForEach(players.prefix(9), id: \.self) { item in
                            Text(String(item))
                                .frame(alignment: .center)
                                .font(.body)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        if players.count > playerCardLimit {
                            Text("\(players.count - playerCardLimit) more...")
                                .frame(alignment: .leading)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 1, height: 150)
                }
            }
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5))
            )
            .padding(.horizontal)
    }
}

#Preview {
    PlayersListCard(players: [
        "BliTz_37", "Emperreur_Bonobo", "TheFantasio974", "batissdeurr",
         "Emperreur_Bonobo7", "Emperreur_Bonobo6", "Emperreur_Bonobo5",
         "Emperreur_Bonobo3", "tom_lafontaine",
     ])
}
