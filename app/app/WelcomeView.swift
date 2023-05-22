//
//  WelcomeView.swift
//  app
//
//  Created by Alejandro D on 05/05/23.
//

import SwiftUI

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
    @Binding var client: Surreal
    @Binding var user: User
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(user.rec_collections, id: \.self.id) { collection in
                        CardView(
                            collection: $user.rec_collections[user.rec_collections.firstIndex(of: collection)!],
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
                guard let res = try? await client.query("SELECT *, fn::is_following(id) FROM collection WHERE <-owns<-(user WHERE id != $auth.id) LIMIT 5").json else {
                    return
                }
                
                user.rec_collections = res.arrayValue.map() { col in
                    Collection.load_collection(from_json: col, issuer: &user)
                }
            }
        }
    }
}

