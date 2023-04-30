//
//  LoginView.swift
//  app
//
//

import SwiftUI


struct LoginView: View {
    @State var user = ""
    @State var pass = ""
    
    @State var registrarUsuario = false
    
    @Binding var global_user: User
    
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
                                if let user = await UserLoginInfo.login(user: user, pass: pass) {
                                    global_user = user
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
                    .sheet(isPresented: $registrarUsuario) {
                        SignupView(is_presented: $registrarUsuario)
                    }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var user = User()
    static var previews: some View {
        LoginView(global_user: $user)
    }
}
