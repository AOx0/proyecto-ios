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

                // Obtener todas las colecciones a las que estamos suscritos
                guard let sus = try? await client.query("SELECT * FROM collection WHERE <-sus<-(user WHERE id = $auth.id)").json else {
                    return
                }
                
                user.own_collections.removeAll()
                user.sus_collections.removeAll()
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
                            user_owned: true,
                            is_suscribed: false
                        )
                    )
                }
                
                for col in sus.arrayValue {
                    user.sus_collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: col["author"].stringValue,
                            description: col["description"].stringValue,
                            pub: col["public"].boolValue,
                            views: col["num_views"].uInt64Value,
                            sus: col["num_sus"].uInt64Value,
                            is_suscribed: true
                        )
                    )
                }
            }
        }
    }
}
