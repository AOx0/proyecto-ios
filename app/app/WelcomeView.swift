//
//  WelcomeView.swift
//  app
//
//  Created by Alejandro D on 05/05/23.
//

import SwiftUI

struct User {
    var id: String = ""
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var gravatar: String = ""
    var gravatar_md5: String = ""
    
    var own_collections = [Collection]()
    var sus_collections = [Collection]()
    var rec_collections = [Collection]()
    
    public mutating func reset() {
        self = User()
    }
}

struct Collection: Equatable {
    var id: String
    var name: String
    var author: String
    var description: String
    var user_owned = false
    var is_suscribed = false
    var cards: [Card] = [Card]()
}

struct Card: Equatable {
    var id: String
    var sentence: String
    var answer: String
}

struct NavButton: View {
    var title: String
    var image: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action){
            VStack {
                Image(systemName: image)
                Text(title)
                    .font(.footnote)
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var client: SurrealDBClient
    @Binding var user: User
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(user.rec_collections, id: \.self.id) { collection in
                        CardView(
                            collection: $user.rec_collections[user.rec_collections.firstIndex(of: collection)!],
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
                guard let res = try? await client.user_query(query: "SELECT *, (<-owns<-user.id)[0] AS owner, count(<-sus<-(user WHERE id = $auth.id)) = 1 AS sus FROM collection WHERE <-owns<-(user WHERE id != $auth.id) LIMIT 5").intoJSON()[0]["result"] else {
                    return
                }
                
                user.rec_collections.removeAll()
                for col in res.arrayValue {
                    user.rec_collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: col["owner"].stringValue,
                            description: col["description"].stringValue,
                            is_suscribed: col["sus"].boolValue
                        )
                    )
                }
            }
        }
    }
}

