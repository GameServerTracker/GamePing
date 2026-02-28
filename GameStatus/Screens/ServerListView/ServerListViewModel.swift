//
//  ServerListViewModel.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI

@Observable
@MainActor final class ServerListViewModel {
    var selectedServer: GameServer? {
        didSet { showAddServerModal = true }
    }
    
    var showAddServerModal: Bool = false
}
