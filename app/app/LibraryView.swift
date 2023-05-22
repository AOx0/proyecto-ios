//
//  LibraryView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI

struct LibraryView: View {
    @Binding var client: Surreal
    @Binding var user: User
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Text("Suscribed")
                    .bold()
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(user.sus_collections, id: \.self.id) { collection in
                        CardView(
                            collection: $user.sus_collections[user.sus_collections.firstIndex(of: collection)!],
                            client: $client,
                            other_user: $user,
                            user: $user
                        )
                    }
                }
            }
            Spacer()
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
        .onAppear() {
            Task{
                // Obtener todas las colecciones de las que somos dueños
                guard let res = try? await client.query("SELECT * FROM collection WHERE <-owns<-(user WHERE id = $auth.id)").json else {
                    return
                }
                
                await user.own_collections = res.arrayValue.asyncMap() { col in
                    await Collection.load_collection(from_json: col, issuer: &user)
                }
                
                // Obtener todas las colecciones a las que estamos suscritos
                guard let sus = try? await client.query("SELECT * FROM collection WHERE <-sus<-(user WHERE id = $auth.id)").json else {
                    return
                }
                
                await user.sus_collections = sus.arrayValue.asyncMap() { col in
                    await Collection.load_collection(from_json: col, issuer: &user)
                }
            }
        }
    }
}
