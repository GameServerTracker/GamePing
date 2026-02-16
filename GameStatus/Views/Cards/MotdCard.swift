//
//  MotdCard.swift
//  GameStatus
//
//  Created by Tom on 13/09/2025.
//

import SwiftUI

struct MotdCard: View {
    @Environment(\.colorScheme) var colorScheme

    var motd: AttributedString
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack(alignment: .center, spacing: 8) {
                Text(motd)
                    .textSelection(.enabled)
            }
            .padding(.horizontal)
            .glassEffect(
                .regular.tint(
                    colorScheme == .dark
                    ? Color(.systemGray4)
                    : Color.black.opacity(0.4)
                ).interactive(),
                in: .rect(cornerRadius: 16.0)
            )
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .center, spacing: 8) {
                Text(motd)
                    .textSelection(.enabled)
            }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        colorScheme == .dark
                            ? Color.white.opacity(0.15)
                            : Color.black.opacity(0.6)
                    )
            )
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MotdCard(motd: "Test")
}
