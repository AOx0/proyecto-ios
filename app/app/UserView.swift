//
//  UserView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI

struct Img {
    var image: Image
    
    init(image: Image, stored_image: inout Image?) {
        self.image = image
        stored_image = self.image
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}

struct UserView: View {
    @Binding var user: User
    @Binding var img: Image?
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                // Si ya tenemos la imagen no la volvemos a descargar, al menos durante el resto
                // de esta corrida
                if let image = img {
                    Img(image: image, stored_image: &img).body
                        .frame(width: 60, height:  60)
                } else {
                    AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(user.gravatar_md5)?s=100")) { phase in
                        switch phase {
                            case .empty:
                                Circle()
                                    .foregroundColor(Color.gray.opacity(0.1))
                            case .success(let image):
                                Img(image: image, stored_image: &img).body // Guardamos y motramos
                            case .failure:
                                Circle()
                                    .foregroundColor(.red)
                            @unknown default:
                                Circle()
                                    .foregroundColor(.red)
                        }
                    }
                    .frame(width: 60, height:  60)
                }
                
                
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
                CardView(title: "Title", author: "AOx0", desc: "Description")
            }
            
            Spacer()
        }
        .padding()
    }
}
