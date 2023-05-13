//
//  CardView.swift
//  app
//
//  Created by Alejandro D on 09/05/23.
//

import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var collection: Collection

    var body: some View {
        NavigationLink {
            Text("Card info")
        } label: {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(collection.name)
                        .font(.headline)
                    Text("by \(collection.author.replacingOccurrences(of: "user:", with: ""))")
                        .font(.footnote)
                }
                Spacer()
                Text(collection.description)
                    .font(.footnote)
            }
            .padding()
            .background() {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray).opacity(0.1)
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
    }
}
