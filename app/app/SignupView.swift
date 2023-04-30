//
//  SignupView.swift
//  app
//
//  Created by Alejandro D on 30/04/23.
//

import SwiftUI

struct SignupView: View {
    
    @State var nombre: String = ""
    
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
                            VStack {
                                Text("Estos datos son necesarios para generar tu perfil")
                                    .foregroundColor(Color("gray_log_in"))
                                
                                TextField("Nombre", text: $nombre)
                                    .frame(height: 20)
                                    .padding()
                                    .textFieldStyle(.plain)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.white)
                                    )
                                    .textInputAutocapitalization(.never)
                                
                                
                            
                                Spacer()
                            }
                            .padding()
                        }
                }.ignoresSafeArea()
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
