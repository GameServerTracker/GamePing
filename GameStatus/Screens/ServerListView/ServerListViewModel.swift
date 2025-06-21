//
//  ServerListViewModel.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI

@MainActor final class ServerListViewModel: ObservableObject {
    var selectedServer: GameServer? {
        didSet { showAddServerModal = true }
    }
    
    @Published var showAddServerModal: Bool = false
}
