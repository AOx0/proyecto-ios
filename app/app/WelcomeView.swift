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
    
    var my_collections: [Collection] = [Collection]()
    var collections: [Collection] = [Collection]()
    
    public mutating func reset() {
        self = User()
    }
}

struct Collection: Identifiable, Equatable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var name: String
    var author: String
    var description: String
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
                    ForEach(user.collections, id: \.self) { collection in
                        CardView(collection: $user.collections[user.collections.firstIndex(of: collection)!] )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear() {
            Task{
                guard let res = try? await client.user_query(query: "SELECT * FROM collection WHERE <-owns<-(user WHERE id != $auth.id)").intoJSON()[0]["result"] else {
                    return
                }
                
                user.collections.removeAll()
                for col in res.arrayValue {
                    user.collections.append(
                        Collection(
                            id: col["id"].stringValue,
                            name: col["name"].stringValue,
                            author: "",
                            description: col["description"].stringValue
                        )
                    )
                }
            }
        }
        
    }
}

