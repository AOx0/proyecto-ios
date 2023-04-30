//
//  CreateGroupView.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI
import MapKit

struct CreateGroupView: View {
    @State var nombre: String = ""
    @State var destination: String = ""
    @State var puntuacion: Float = 4.5

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Crear grupo")
                    .bold()
                    .font(.title2)
                Spacer()
            }
            
            TextField("Nombre del grupo", text: $nombre)
                .frame(height: 20)
                .padding()
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("gray_log_in"))
                )
                .textInputAutocapitalization(.never)
            
            VStack {
                Text("Puntuación minima: \(String(format: "%.2f", puntuacion))")
                Slider(
                    value: $puntuacion,
                    in: 0...5
                )
            }
            
            TextField("Dirección/destino", text: $destination)
                .frame(height: 20)
                .padding()
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("gray_log_in"))
                )
                .textInputAutocapitalization(.never)
            
            Spacer()
        }.padding()
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
