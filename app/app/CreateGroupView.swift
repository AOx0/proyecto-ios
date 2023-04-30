//
//  CreateGroupView.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI
import MapKit

struct CreateGroupView: View {
    @State var new_group = GroupCreation()
    @Binding var groups: [GroupInfo]
    @Binding var user: User
    @Binding var active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Crear grupo")
                    .bold()
                    .font(.title2)
                Spacer()
            }
            
            TextField("Nombre del grupo", text: $new_group.nombre)
                .frame(height: 20)
                .padding()
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("gray_log_in"))
                )
                .textInputAutocapitalization(.never)
            
            VStack {
                Text("Puntuación minima: \(String(format: "%.2f", new_group.puntuacion))")
                Slider(
                    value: $new_group.puntuacion,
                    in: 0...5
                )
            }
            
            TextField("Dirección/destino", text: $new_group.destination)
                .frame(height: 20)
                .padding()
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("gray_log_in"))
                )
                .textInputAutocapitalization(.never)
            
            Button("Create group") {
                Task {
                    await new_group.create_group(id: user.id)
                    if let tmp = await user.get_groups() {
                        groups = tmp
                    }
                    active = false
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("gray_log_in"))
            )
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }.padding()
    }
}


