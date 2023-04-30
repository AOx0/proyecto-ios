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
    @State var groups = [GroupInfo]()
    
    @State var creando_grupo = false
    
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
            Color.white
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
                            .fill(Color("gray_log_in"))
                    )
                    .textInputAutocapitalization(.never)
                
                Text("Grupos recientes")
                    .font(.title2)
                    .bold()
                
                Text("Nuevo Grupo")
                    .font(.title2)
                    .bold()
                
                Button(action: {
                    creando_grupo.toggle()
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
                .background(Color("gray_log_in"))
                .cornerRadius(10)
                
                Text("Mis grupos")
                    .font(.title2)
                    .bold()
                
                ScrollView {
                    ForEach(groups) { group in
                        NavigationLink {
                            GroupDetailsView(group: $groups[groups.firstIndex(of: group)!])
                                .foregroundColor(.black)
                        } label: {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading) {
                                    Text(group.nombre)
                                    Spacer()
                                    HStack {
                                        Image(systemName: "map.fill")
                                        Text(group.direccion)
                                            .font(.footnote)
                                    }
                                }
                                Spacer()
                                Image(systemName: "car.fill")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("gray_log_in"))
                            )
                            .foregroundColor(.black)
                        }
                        
                    }
                }
            }
            .padding()
            .onAppear() {
                Task {
                    if !user.is_default() {
                        if let tmp = await user.get_groups() {
                            groups = tmp
                        }
                    }
                    
                }
            }
            .sheet(isPresented: $creando_grupo) {
                CreateGroupView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var user = User()
    static var previews: some View {
        HomeView(user: $user)
    }
}
