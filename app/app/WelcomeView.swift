//
//  WelcomeView.swift
//  app
//
//  Created by Alejandro D on 05/05/23.
//

import SwiftUI

struct User {
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var gravatar: String = ""
    var gravatar_md5: String = ""
    
    public mutating func reset() {
        self = User()
    }
}

struct Collection: Identifiable {
    var id: String
    var name: String
    var tags: [String]
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
    @Binding var user: User
    @State var collections = [Collection]()
    
    var body: some View {
        VStack {
            ForEach($collections) { collection in
                VStack {
                    Text("\(collection.name.wrappedValue)")
                    HStack {
                        ForEach(collection.tags, id: \.self) { tag in
                            Text("\(tag.wrappedValue)")
                        }
                    }
                }
            }
        }
        .padding()
        
    }
}

