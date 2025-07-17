//
//  StringProtocol+ext.swift
//  GameStatus
//
//  Created by Tom on 16/07/2025.
//

extension StringProtocol {
    public var firstUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
}
