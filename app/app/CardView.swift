//
//  CardView.swift
//  app
//
//  Created by Alejandro D on 09/05/23.
//

import SwiftUI
import SwiftyJSON


struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var collection: Collection
    @Binding var client: Surreal
    @Binding var other_user: User
    @Binding var user: User

    var body: some View {
        Group {
            NavigationLink {
                VStack {
                    Text(collection.description)
                    if collection.pub {
                        HStack(spacing: 5.0) {
                            Image(systemName: "eye.fill")
                            Text("\(collection.views)")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 5.0) {
                            Image(systemName: collection.is_suscribed ? "star.fill" : "star")
                            Text("\(collection.sus)")
                        }
                        .font(.caption2)
                    }
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
                                    let _ = try? await client.query("UPDATE type::thing($auth.id) SET suscribe_to = \(collection.id)")
                                    guard let res = try? await client.query("RETURN SELECT count(<-sus<-(user WHERE id = $auth.id)) = 1 AS is_sus, num_sus FROM \(collection.id)").json else {
                                        return
                                    }
                                    
                                    // Update suscription status whith the actual data
                                    collection.is_suscribed = res["is_sus"].boolValue
                                    collection.sus = res["num_sus"].uInt64Value
                                }
                                
                                
                            }
                        }
                    }
                }
                .onAppear() {
                    Task {
                        if collection.pub {
                            let _ = try? await client.query("UPDATE \(user.id) SET view_collection = \(collection.id)")
                        }
                        guard let views_res: JSON = try? await client.query("RETURN SELECT VALUE num_views FROM \(collection.id)").json else { return }
                        collection.views = views_res.uInt64Value
                    }
                }
            } label: {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(collection.name)
                            .font(.headline)
                        
                        NavigationLink {
                            if user.id == collection.author {
                                UserView(client: $client, user: $user)
                                    .padding()
                            } else {
                                OtherUserView(client: $client, id: collection.author, user: $user)
                                    .padding()
                            }
                        } label: {
                            Text("by \(collection.author.replacingOccurrences(of: "user:", with: ""))")
                                .font(.footnote)
                        }
                    }
                    Spacer()
                    
                    if collection.pub {
                        HStack(spacing: 5.0) {
                            Image(systemName: "eye.fill")
                            Text("\(collection.views)")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 5.0) {
                            Image(systemName: (collection.is_suscribed || collection.user_owned) ? "star.fill" : "star")
                            Text("\(collection.sus)")
                        }
                        .font(.caption2)
                    }
                }
                .padding()
                .background() {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.gray).opacity(0.1)
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
        }
        .onAppear() {
            Task {
                if collection.pub {
                    guard let views_res: JSON = try? await client.query("RETURN SELECT num_sus, num_views FROM \(collection.id)").json else { return }
                    collection.views = views_res["num_views"].uInt64Value
                    collection.sus = views_res["num_sus"].uInt64Value
                }
            }
        }
    }
}
