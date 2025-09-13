//
//  TagsListCard.swift
//  GameStatus
//
//  Created by Tom on 16/08/2025.
//

import SwiftUI

struct TagsListCard: View {
    let tags: [String]
    
    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]
    
    private let tagCardLimit: Int = 6

    var body: some View {
        CardContainer {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Label("Tags", systemImage: "number")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.brandPrimary)
                }
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(tags.prefix(5), id: \.self) { tag in
                        if (!tag.isEmpty) {
                            Text(tag)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .fontWeight(.light)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    if tags.count > tagCardLimit {
                        Text("\(tags.count - tagCardLimit) more...")
                            .frame(alignment: .leading)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    TagsListCard(tags: [
        "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:2ff48302805", "gmc:rp", "loc:fr", "ver:250509"
    ])
}
