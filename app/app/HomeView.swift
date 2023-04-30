//
//  HomeView.swift
//  app
//
//  Created by Alejandro D on 30/04/23.
//

import SwiftUI

struct HomeView: View {
    @State var search_text: String = ""
    
    @Binding var user: User
    
    func hi_msg() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
            case 0..<6:
                return "Buenas noches"
            case 6..<12:
                return "Buenos días"
            case 12..<18:
                return "Buenas tardes"
            default:
                return "Buenas noches"
        }
    }
    
    var body: some View {
        ZStack{
            Color("gray_log_in")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Text(hi_msg())
                        .bold()
                    Spacer()
                    Image(systemName: "person.fill")
                    Image(systemName: "bell.fill")
                }
                .font(.title2)
                
                TextField("Buscar un grupo", text: $search_text)
                    .frame(height: 20)
                    .padding()
                    .textFieldStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                    )
                    .textInputAutocapitalization(.never)
                
                Text("Grupos recientes")
                    .font(.title2)
                    .bold()
                
                Text("Mis grupos")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Text("Nuevo Grupo")
                    .font(.title2)
                    .bold()
                
                Button(action: {
                    
                }) {
                    HStack {
                        Text("Crea un nuevo grupo")
                        Spacer()
                        Image(systemName: "plus")
                    }
                    .padding()
                    .foregroundColor(.black)
                    .bold()
                }
                .background(.white)
                .cornerRadius(10)
                
                
            }
            .padding()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var user = User()
    static var previews: some View {
        HomeView(user: $user)
    }
}
