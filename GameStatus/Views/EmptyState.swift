//
//  EmptyState.swift
//  Appetizer
//
//  Created by Tom on 09/05/2025.
//

import SwiftUI

struct EmptyState: View {
    
    let title: String;
    let imageName: String;
    
    var body: some View {
        ZStack {
            Color(.background)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150, alignment: .center)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
            }.offset(y: -50)
        }
    }
}

#Preview {
    EmptyState(title: "No servers added\n Click the plus button to add one", imageName: "serverLogoUnique")
}
