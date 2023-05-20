//
//  UserView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI

struct OtherUserView: View {
    @Binding var client: Surreal
    var id: String
    
    // Información del usuario actual
    @Binding var user: User
    
    // La información del otro usuario se carga aqui
    @State var other_user: User = User()
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                // Si ya tenemos la imagen no la volvemos a descargar, al menos durante el resto
                // de esta corrida
                
                AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(other_user.gravatar_md5)?s=100")) { phase in
                    switch phase {
                        case .empty:
                            Circle()
                                .foregroundColor(Color.gray.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .foregroundColor(.red)
                        @unknown default:
                            Circle()
                                .foregroundColor(.red)
                    }
                }
                .frame(width: 60, height:  60)
                
                
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text(other_user.first_name)
                            .font(.title)
                        Text(other_user.last_name)
                            .font(.title)
                    }
                    
                    Text("123 followers")
                        .font(.footnote)
                    Text("323 following")
                        .font(.footnote)
                    
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                Button(other_user.following ? "Unfollow" : "Follow") {
                    other_user.following = !other_user.following
                    Task {
                        let _ = try! await client.query("UPDATE type::thing($auth.id) SET follow_user = \(id)")
                        
                        // Update suscription status whith the actual data
                        let res = try! await client.query("RETURN fn::is_following( \(other_user.id))").json

                        other_user.following = res.boolValue
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
            
            HStack {
                Text("Collections")
                    .bold()
                Spacer()
            }
            
            ScrollView {
                VStack {
                    ForEach(other_user.own_collections, id: \.self.id) { collection in
                        CardView(
                            collection: $other_user.own_collections[other_user.own_collections.firstIndex(of: collection)!],
                            client: $client,
                            other_user: $other_user,
                            user: $user
                        )
                    }
                }
            }
            
            Spacer()
        }
        .onAppear() {
            Task{
                guard let info = try? await client.query("RETURN SELECT *, fn::is_following(id) FROM \(id)").json else {
                    return
                }

                other_user.id = info["id"].stringValue
                other_user.first_name = info["first_name"].stringValue
                other_user.last_name = info["last_name"].stringValue
                other_user.gravatar_md5 = info["gravatar_md5"].stringValue
                other_user.following = info["fn::is_following"].boolValue
                
                // Cargar colecciones
                guard let res = try? await client.query("SELECT * FROM collection WHERE <-owns<-(user WHERE id = \(id))").json else {
                    return
                }
                
                other_user.own_collections.removeAll()
                for col in res.arrayValue {
                    other_user.own_collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: other_user.id,
                            description: col["description"].stringValue,
                            pub: col["public"].boolValue,
                            views: col["num_views"].uInt64Value,
                            sus: col["num_sus"].uInt64Value,
                            user_owned: false,
                            is_suscribed: col["is_sus"].boolValue
                        )
                    )
                }
            }
        }
    }
}


struct UserView: View {
    @Binding var client: Surreal
    
    @Binding var user: User
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                // Si ya tenemos la imagen no la volvemos a descargar, al menos durante el resto
                // de esta corrida
                
                AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(user.gravatar_md5)?s=100")) { phase in
                    switch phase {
                        case .empty:
                            Circle()
                                .foregroundColor(Color.gray.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .foregroundColor(.red)
                        @unknown default:
                            Circle()
                                .foregroundColor(.red)
                    }
                }
                .frame(width: 60, height:  60)
                
                
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text(user.first_name)
                            .font(.title)
                        Text(user.last_name)
                            .font(.title)
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text(user.email.isEmpty ? "No mail registered" : user.email)
                           
                    }
                    .font(.footnote)
                    
                    HStack {
                        Image(systemName: "photo.fill")
                        Text(user.gravatar.isEmpty ? "No gravatar registered" : user.gravatar)
                           
                    }
                    .font(.footnote)
                }
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("Your collections")
                    .bold()
                Spacer()
            }
            
            ScrollView {
                VStack {
                    ForEach(user.own_collections, id: \.self.id) { collection in
                        CardView(
                            collection: $user.own_collections[user.own_collections.firstIndex(of: collection)!],
                            client: $client,
                            other_user: $user,
                            user: $user
                        )
                    }
                }
            }
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Log out") {
                    // Borrar toda la información del usuario del estado
                    client.reset_auth()
                    user.reset()
                }
            }
        }
        .onAppear() {
            Task{
                guard let res = try? await client.query("SELECT * FROM collection WHERE <-owns<-(user WHERE id = $auth.id)").json else {
                    return
                }
                
                user.own_collections.removeAll()
                for col in res.arrayValue {
                    user.own_collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: user.id,
                            description: col["description"].stringValue,
                            pub: col["public"].boolValue,
                            views: col["num_views"].uInt64Value,
                            sus: col["num_sus"].uInt64Value,
                            user_owned: true
                        )
                    )
                }
            }
        }
    }
}
