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
    
    @State var client: Surreal = Surreal(address: "34.125.0.154:8000")
    
    @State var email = "daniel@gmail.com"
    @State var pass = "1234"
    
    @State var currentView = 1
    
    var body: some View {
        ZStack {
            if user.email.isEmpty {
                LoginView()
            } else {
                AppView()
            }
        }
        .onAppear() {
            // Comenzar la conexión con el WebSocket
            if case .Connecting = client.state {
                Task {
                    try! await client.start()
                }
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
            
            HStack {
                Button("Log In") {
                    Task {
                        
                        
                        if (try await client.login(mail: email, pass: pass)) != nil {
                            try await client.authenticate()
                            await user.load_user(for_id: "$auth.id", client: &client)
                            
                            currentView = 1
                            email = ""
                            pass = ""
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Register") {
                    
                }
                .buttonStyle(.borderedProminent)
            }
        }.padding()
    }
    
    fileprivate func AppView() -> NavigationView<some View> {
        return NavigationView {
            VStack {
                switch currentView {
                case 1: WelcomeView(client: $client, user: $user)
                        .navigationTitle("Bienvenido, \(user.first_name.capitalized)".trimmingCharacters(in: [" ", ","]) + "!")
                case 2: LibraryView(client: $client, user: $user)
                        .navigationTitle("Library")
                case 3: SearchView()
                        .navigationTitle("Search")
                case 4: UserView(client: $client, user: $user)
                        .navigationTitle("Account")
                default: WelcomeView(client: $client, user: $user)
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
