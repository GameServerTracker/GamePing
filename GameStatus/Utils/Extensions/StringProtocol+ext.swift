//
//  StringProtocol+ext.swift
//  GameStatus
//
//  Created by Tom on 16/07/2025.
//

import Foundation

extension StringProtocol {
    public var firstUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
    
    public var isHexColor: Bool {
        let regex = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$"
        return self.range(of: regex, options: .regularExpression) != nil
    }
}
