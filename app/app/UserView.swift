//
//  UserView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI

struct UserView: View {
    @Binding var user: User
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                AsyncImage(url: URL(string: "https://www.gravatar.com/avatar/\(user.gravatar_md5)?s=500")) { phase in
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
                            .foregroundColor(.red) // or any error indicator you prefer
                    @unknown default:
                        Circle()
                            .foregroundColor(.red) // or any unknown indicator you prefer
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
                        Text(user.email)
                           
                    }
                    .font(.footnote)
                    
                    HStack {
                        Image(systemName: "photo.fill")
                        Text(user.gravatar)
                           
                    }
                    .font(.footnote)
                }
                Spacer()
            }
        }
        .padding()
    }
}
