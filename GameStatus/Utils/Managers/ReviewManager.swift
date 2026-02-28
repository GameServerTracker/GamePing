//
//  ReviewManager.swift
//  GameStatus
//
//  Created by Tom on 24/01/2026.
//

import Foundation

enum ReviewCriteria {
    case addServer
    case editServer
}

struct ReviewManager {
    // Requirement for show review pop-up
    private let minServerAddCount: Int = 3;
    private let minServerEditCount: Int = 5;
    
    // UserDefaults keys
    private let hasReviewedKey: String = "hasReviewed"
    private let serverAddCountKey: String = "serverAddedCount"
    private let serverEditCountKey: String = "serverEditedCount"
    
    func requestReviewIfNeeded(criteria: ReviewCriteria, requestReview: @escaping () -> Void) {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: hasReviewedKey) {
            return;
        }
        
        switch criteria {
        case .addServer:
            let newCount = defaults.integer(forKey: serverAddCountKey) + 1
            defaults.set(newCount, forKey: serverAddCountKey)
            if newCount < minServerAddCount {
                return;
            }
        case .editServer:
            let newCount = defaults.integer(forKey: serverEditCountKey) + 1
            defaults.set(newCount, forKey: serverEditCountKey)
            if newCount < minServerEditCount {
                return;
            }
        }
        requestReview()
        defaults.set(true, forKey: hasReviewedKey)
    }
}
