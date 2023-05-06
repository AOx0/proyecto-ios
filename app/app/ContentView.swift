//
//  ContentView.swift
//  app
//
//  Created by Alejandro D on 04/05/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var user = User()
    @State var client = SurrealDBClient(url: "http://187.208.119.8:8000")
    @State var email = "daniel@gmail.com"
    @State var pass = "1234"
    
    @State var currentView = 1
    
    var body: some View {
        ZStack {
            if user.email != "" {
                AppView()
            } else {
                LoginView()
            }
        }
    }
    
    fileprivate func LoginView() -> some View {
        return VStack{
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $pass)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            
            Button("Test") {
                Task {
                    if (try? await client.login(mail: email, pass: pass)) != nil {
                        guard let res = try? await client.user_query(query: "SELECT email, first_name, last_name, gravatar, gravatar_md5 FROM $auth.id").intoJSON() else {
                            return
                        }
                        
                        let info = res[0]["result"][0]
                        user.email = info["email"].stringValue
                        user.first_name = info["first_name"].stringValue
                        user.last_name = info["last_name"].stringValue
                        user.gravatar = info["gravatar"].stringValue
                        user.gravatar_md5 = info["gravatar_md5"].stringValue
                        currentView = 1
                        
                        email = ""
                        pass = ""
                    }
                }
            }
        }.padding()
    }
    
    fileprivate func AppView() -> NavigationView<some View> {
        return NavigationView {
            VStack {
                switch currentView {
                case 1: WelcomeView(user: $user)
                        .navigationTitle("Bienvenido, \(user.first_name.capitalized)".trimmingCharacters(in: [" ", ","]) + "!")
                case 2: LibraryView()
                        .navigationTitle("Library")
                case 3: SearchView()
                        .navigationTitle("Search")
                case 4: UserView(user: $user)
                        .navigationTitle("Account")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Log out") {
                                    client.reset_auth()
                                    user.reset()
                                }
                            }
                        }
                default: WelcomeView(user: $user)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    NavButton(title: "Library", image: "rectangle.fill.on.rectangle.fill") { currentView = 2 }
                        .opacity(currentView == 2 ? 0.5 : 1.0)
                    Spacer()
                    NavButton(title: "Browse", image: "rectangle.grid.2x2.fill") { currentView = 1 }
                        .opacity(currentView == 1 ? 0.5 : 1.0)
                    Spacer()
                    NavigationLink {
                        CreateCollection(currentView: $currentView)
                    } label: {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New")
                                .font(.footnote)
                        }
                    }
                    Spacer()
                    NavButton(title: "Search", image: "magnifyingglass.circle.fill") { currentView = 3 }
                        .opacity(currentView == 3 ? 0.5 : 1.0)
                    Spacer()
                    NavButton(title: "Account", image: "person.fill") { currentView = 4 }
                        .opacity(currentView == 4 ? 0.5 : 1.0)
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
