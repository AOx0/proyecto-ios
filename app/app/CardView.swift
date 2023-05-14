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
    @Binding var client: SurrealDBClient
    @Binding var user: User

    var body: some View {
        NavigationLink {
            VStack {
                Text(collection.description)
                Spacer()
            }
            .padding()
            .navigationTitle(Text(collection.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !collection.user_owned {
                        Button(collection.is_suscribed  ? "Unsuscribe" : "Suscribe") {
                            // Assume a successfull process to suscribe/unsuscribe
                            collection.is_suscribed = !collection.is_suscribed
                            
                            // Actually suscribe/unsuscribe
                            Task {
                                // IMPORTANT: Here we inverse-check because we already toggled the value
                                if !collection.is_suscribed {
                                    let _ = try? await client.user_query(query: "DELETE FROM \(user.id)->sus WHERE out=\(collection.id);")
                                } else {
                                    let _ = try? await client.user_query(query: "UPDATE \(user.id) SET suscribe_to = \(collection.id)")
                                }
                                
                                guard let res = try? await client.user_query(query: "SELECT count(<-sus<-(user WHERE id = $auth.id)) = 1 AS sus FROM \(collection.id)").intoJSON()[0]["result"][0] else {
                                    return
                                }
                                
                                // Update suscription status whith the actual data
                                collection.is_suscribed = res["sus"].boolValue
                            }
                            
                            
                        }
                    }
                }
            }
        } label: {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(collection.name)
                        .font(.headline)
                    Text("by \(collection.author.replacingOccurrences(of: "user:", with: ""))")
                        .font(.footnote)
                }
                Spacer()
                Text(collection.is_suscribed ? "Suscribed" : "")
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
