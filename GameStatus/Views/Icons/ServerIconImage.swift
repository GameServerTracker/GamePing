//
//  ServerIconImage.swift
//  GameStatus
//
//  Created by Tom on 31/05/2025.
//

import SwiftUI

struct ServerIconImage: View {

    let base64Image: String?

    private func decodeBase64Image(_ base64String: String) -> Data? {
        let base64 = base64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
        return Data(base64Encoded: base64)
    }
    
    var body: some View {
        if let base64String = base64Image,
           let imageData = decodeBase64Image(base64String),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        } else {
            ServerIconDefault(
                iconImage: Image("serverLogo"),
                gradientColors: [.brandPrimary],
                iconSize: 52
            )
        }
    }
}

#Preview {
    ServerIconImage(base64Image: nil)
        .frame(width: 128, height: 128)
}
