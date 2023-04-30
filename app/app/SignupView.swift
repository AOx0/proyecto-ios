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

struct User: Codable {
    enum CodingKeys: CodingKey {
        case nombre, apellido, fecha_nacimiento, correo, telefono, password
    }
    
    var nombre: String = ""
    var apellido: String = ""
    var fecha_nacimiento: String = ""
    var correo: String = ""
    var telefono: String = ""
    var password: String = ""
    var pass2: String = ""
    
    // Returns an string when it fails
    func register() async -> String? {
        let url = URL(string: "https://cf95-192-100-230-250.ngrok.io/register")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if dateFormatter.date(from: self.fecha_nacimiento) == nil {
            return "Fecha invalida: formato yyyy-MM-dd"
        }
        
        if let body = try? JSONEncoder().encode(self) {
            req.httpBody = body
        } else { return "Error al serializar" }
        
        if let (_, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 201 {
                return nil
            } else if httpResponse?.statusCode == 302 {
                return "El usuario existe"
            }
        } else {
            return "Error al obtener"
        }
        
        return "Error"
    }
}

struct SignupView: View {
    
    @Binding var is_presented: Bool
    
    @State var user = User()
    @State var error_msg = ""
    
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
                                TextFieldA(name: "Verificar contraseña", field: $user.pass2)

                                Button(action: {
                                    Task {
                                        if let error = await user.register() {
                                            error_msg = error
                                        } else {
                                            is_presented = false
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
