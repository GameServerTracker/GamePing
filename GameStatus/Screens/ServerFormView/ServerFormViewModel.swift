//
//  ServerFormViewModel.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI

final class ServerFormViewModel: ObservableObject {
    @Published var serverName: String = ""
    @Published var serverAddress: String = ""
    @Published var serverPort: Int? = nil
    @Published var serverType: GameServerType = .minecraft
}
