//
//  WelcomeView.swift
//  app
//
//  Created by Alejandro D on 30/04/23.
//

import SwiftUI

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

struct WelcomeView_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        WelcomeView(showing: $show)
    }
}
