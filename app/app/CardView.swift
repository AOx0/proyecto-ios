//
//  CardView.swift
//  app
//
//  Created by Alejandro D on 09/05/23.
//

import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let author: String
    let desc: String
    var body: some View {
        NavigationLink {
            Text("Card info")
        } label: {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text("by \(author)")
                        .font(.footnote)
                }
                Spacer()
                Text(desc)
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
