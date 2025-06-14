//
//  ServerDetailsView.swift
//  GameStatus
//
//  Created by Tom on 08/06/2025.
//

import SwiftUI

struct ServerDetailsView: View {
    let server: GameServer

    var body: some View {
        VStack() {
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
                HStack {
                    ForEach(0..<5) { _ in
                        VStack (alignment: .center) {
                            Text("Max Players".uppercased())
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .fontWeight(.bold)
                            Text("10 000")
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                                .font(.callout)
                            Text("Players")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }.padding(.top, 10)
                        Divider().frame(height: 50)
                    }
                }.padding(.top, 2)
                
            }.overlay(Divider(), alignment: .top)
                .padding(.top, 5)
                .padding()
            Spacer()
            Text("Players")
            Spacer()
        }.background(Color.background)
    }
}

#Preview {
    ServerDetailsView(server: MockData.gameServers.last!)
}
