//
//  SignupView.swift
//  app
//
//  Created by Alejandro D on 30/04/23.
//

import SwiftUI

struct TextFieldA: View {
    var name: String
    @Binding var field: String
    var body: some View {
        TextField(name, text: $field)
            .frame(height: 20)
            .padding()
            .textFieldStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
            )
            .textInputAutocapitalization(.never)
    }
}

struct SignupView: View {
    
    @Binding var is_presented: Bool
    
    @State var user = UserRegister()
    @State var error_msg = ""
    
    @State var pass2  = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Color("gray_log_in")
                        .frame(height: geo.size.height/6)
                        .overlay {
                            VStack {
                                Spacer()
                                HStack {
                                    Image(systemName: "arrow.backward")
                                        .onTapGesture {
                                            is_presented.toggle()
                                        }
                                    Spacer()
                                    Text("Registra tus datos")
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                            }.padding()
                        }
                    Color("blue_principal")
                        .frame(maxHeight: .infinity)
                        .overlay {
                            VStack(spacing: 20) {
                                Text("Estos datos son necesarios para generar tu perfil")
                                    .foregroundColor(Color("gray_log_in"))
                                
                                Text(error_msg)
                                    .foregroundColor(Color("gray_log_in"))
                                
                                TextFieldA(name: "Nombre", field: $user.nombre)
                                TextFieldA(name: "Apellido", field: $user.apellido)
                                TextFieldA(name: "Fecha de nacimiento", field: $user.fecha_nacimiento)
                                TextFieldA(name: "Correo", field: $user.correo)
                                TextFieldA(name: "Telefono", field: $user.telefono)
                                TextFieldA(name: "Constraseña", field: $user.password)
                                TextFieldA(name: "Confirmar contraseña", field: $pass2)


                                Button(action: {
                                    Task {
                                        if pass2 != user.password {
                                            error_msg = "Las contraseñas deben coincidir"
                                        } else {
                                            if let error = await user.register() {
                                                error_msg = error
                                            } else {
                                                is_presented = false
                                            }
                                        }
                                    }
                                }) {
                                    Text("Registrar")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                    .background(Color("blue_log_in"))
                                    .cornerRadius(10)
                                
                                
                            }
                            .padding()
                        }
                }.ignoresSafeArea()
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    @State static var show: Bool = true
    
    static var previews: some View {
        SignupView(is_presented: $show)
    }
}
