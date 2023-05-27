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
                    if collection.pub {
                        HStack {
                            Spacer()
                            
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
                    
                    Text(collection.description)
                    
                    Divider()
                    
                    ForEach(collection.cards, id: \.self.id) { card in
                        Text(card.id)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(Text(collection.name))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !collection.user_owned && collection.pub {
                            Button(collection.is_suscribed  ? "Unsuscribe" : "Suscribe") {
                                // Asumimos que la suscripcion es exitosa
                                collection.is_suscribed = !collection.is_suscribed
                                // Cambiamos el conteo de subs de forma inmediata ?
                                if collection.is_suscribed {
                                    collection.sus += 1
                                } else {
                                    collection.sus -= 1
                                }
                                
                                // Realizamos la accion en el servidor
                                Task {
                                    // IMPORTANT: Here we inverse-check because we already toggled the value
                                    let _ = try? await client.query("UPDATE type::thing($auth.id) SET suscribe_to = \(collection.id)")
                                    guard let res = try? await client.query("RETURN SELECT fn::is_sus(id), num_sus FROM \(collection.id)").json else {
                                        return
                                    }
                                    
                                    // Actualizamos los datos reales reflejando la accion
                                    collection.is_suscribed = res["fn::is_sus"].boolValue
                                    collection.sus = res["num_sus"].uInt64Value
                                }
                                
                                
                            }
                        }
                    }
                }
                .onAppear() {
                    Task {
                        // Incrementa el numero de views al instante
                        if collection.pub && !collection.user_owned { collection.views += 1 }
                        
                        // Cargar las cartas de la coleccion
                        await collection.load_cards(client: &client)
                        
                        // Cargar el numero de views real
                        if collection.pub && !collection.user_owned {
                            try await client.query("UPDATE \(user.id) SET view_collection = \(collection.id)")
                            
                            guard let views_res: JSON = try? await client.query("RETURN SELECT VALUE num_views FROM \(collection.id)").json else { return }
                            collection.views = views_res.uInt64Value
                        }
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
                                    .navigationTitle("Account")
                            } else {
                                OtherUserView(client: $client, id: collection.author, user: $user)
                                    .padding()
                                    .navigationTitle("u/\(collection.author.replacingOccurrences(of: "user:", with: ""))")
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
    }
}
