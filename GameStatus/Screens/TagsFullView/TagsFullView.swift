//
//  TagsFullView.swift
//  GameStatus
//
//  Created by Tom on 23/08/2025.
//

import SwiftUI

struct TagRow: Identifiable {
    let id = UUID()
    let name: String
}

struct TagsFullView: View {
    let tags: [String]
    
    var body: some View {
        ZStack {
            Color(.background)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(tags.map { TagRow(name: $0) }) { tagRow in
                    if (!tagRow.name.isEmpty) {
                        TagsFullRow(tag: tagRow.name)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Tags")
        }
    }
}

struct TagsFullRow: View {
    let tag: String

    var body: some View {
        HStack {
            Text(tag)
                .font(.headline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    TagsFullView(tags: [
        "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "gmc:rp", "loc:fr", "ver:250509", "gm:darkrp", "gmws:248302805", "", "loc:fr", "ver:250509", "gm:darkrp", "gmws:2ff48302805", "gmc:rp", "loc:fr", "ver:250509", ""
     ])
}
