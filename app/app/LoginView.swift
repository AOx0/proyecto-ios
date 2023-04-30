//
//  LoginView.swift
//  app
//
//

import SwiftUI

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

struct LoginView: View {
    @State var user = ""
    @State var pass = ""
    
    @State var registrarUsuario = false
    
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
                            registrarUsuario.toggle()
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
