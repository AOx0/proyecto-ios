//
//  ContentView.swift
//  0243179_projecto
//
//  Created by iOS Lab on 29/04/23.
//

import SwiftUI

struct ContentView: View {
    @State var show_welcome: Bool = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    
    var body: some View {
        NavigationView {
            ZStack{
                WelcomeView(showing: $show_welcome)
                    .opacity(show_welcome ? 1 : 0)
                    .animation(.easeOut, value: show_welcome)
                    .zIndex(2)
                Inicio()
                    .zIndex(1)
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var showing: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Color("blue_principal")
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bienvenido")
                                .bold()
                                .font(.largeTitle)
                                .foregroundColor(Color("white"))
                            
                            Spacer()
                            
                            Text("¿ Por qué usar ?")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color("white"))
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                
                    Button(action: {
                        showing = false
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color("blue_log_in"))
                    .cornerRadius(10)
                    
                }.padding()
            }
        }
    }
}

struct GroupInfo: Codable {
    var id_conductor: Int32
    var automovil: Int64
    var puntuacion_min: Int64
    var id_grupo: Int64
    var id_owner: Int32
    
    static func group_info(id: Int64) async -> GroupInfo? {
        let url = URL(string: "https://d27a-2806-2f0-9141-9600-92de-80ff-fe5b-9ace.ngrok.io/group/\(id)")!
        if let (data, _) = (try? await URLSession.shared.data(from: url) ) {
            let info = try? JSONDecoder().decode(GroupInfo.self, from: data)
            return info
        }
        
        return nil
    }
}

struct UserLoginInfo: Encodable {
    var correo: String
    var password: String
    
    static func login(user: String, pass: String) async -> Bool {
        let url = URL(string: "https://d27a-2806-2f0-9141-9600-92de-80ff-fe5b-9ace.ngrok.io/login")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = UserLoginInfo(correo: user, password: pass)
        if let body = try? JSONEncoder().encode(user) {
            req.httpBody = body
        } else { return false }
        
        if let (_, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 202 {
                return true
            }
        }
        
        return false
    }
}

struct Inicio: View {
    @State var user = ""
    @State var pass = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color("blue_principal").ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    
                    HStack(alignment: .center) {
                        
                        Text("Inicia sesión en tu cuenta")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("white"))
                        
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 20) {
                        TextField("Username", text: $user)
                        .frame(height: 20)
                        .padding()
                        .textFieldStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                        .textInputAutocapitalization(.never)
                        
                        TextField("Password", text: $pass)
                        .frame(height: 20)
                        .padding()
                        .textFieldStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                        .textInputAutocapitalization(.never)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            Task {
                                if let res = await GroupInfo.group_info(id: 1) {
                                    print(res)
                                }
                                if await UserLoginInfo.login(user: user, pass: pass) {
                                    print("Logged in")
                                } else {
                                    print("Error")
                                }
                            }
                        }) {
                            Text("Log In")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color("blue_log_in"))
                        .cornerRadius(10)
                        
                        Button(action: {
                            // Sign in button tapped
                        }) {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color("blue_log_in"))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }.padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
