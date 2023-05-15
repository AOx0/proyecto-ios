//
//  LibraryView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI

struct LibraryView: View {
    @Binding var client: SurrealDBClient
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
                            user: $user
                        )
                    }
                }
            }
            Spacer()
        }
        .onAppear() {
            Task{
                guard let res = try? await client.exec("SELECT *, count(<-sus<-user.id) as sus, count(<-view<-user.id) as views FROM collection WHERE <-owns<-(user WHERE id = $auth.id)").intoJSON()[0]["result"] else {
                    return
                }
                // SELECT * FROM collection WHERE <-sus<-(user WHERE id = user:daniel)
                guard let sus = try? await client.exec("SELECT *, (<-owns.in)[0] as owner, count(<-sus<-user.id) as sus, count(<-view<-user.id) as views FROM collection WHERE <-sus<-(user WHERE id = $auth.id)").intoJSON()[0]["result"] else {
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
                            views: col["views"].uInt64Value,
                            sus: col["sus"].uInt64Value,
                            user_owned: true
                        )
                    )
                }
                
                for col in sus.arrayValue {
                    user.sus_collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: col["owner"].stringValue,
                            description: col["description"].stringValue,
                            pub: col["public"].boolValue,
                            views: col["views"].uInt64Value,
                            sus: col["sus"].uInt64Value,
                            is_suscribed: true
                        )
                    )
                }
            }
        }
    }
}
