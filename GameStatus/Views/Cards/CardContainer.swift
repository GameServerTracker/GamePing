//
//  CardContainer.swift
//  GameStatus
//
//  Created by Tom on 13/09/2025.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content.padding()
                .glassEffect(.regular.tint(Color(.systemGray5)).interactive(), in: .rect(cornerRadius: 16.0))
                .padding(.horizontal)
        } else {
            content.padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                )
                .padding(.horizontal)
        }
    }
}
