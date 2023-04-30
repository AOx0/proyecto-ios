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
        ZStack{
            Color("blue_principal")
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Bienvenido")
                            .bold()
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading) {
                            Text("Mismo destino?")
                                .font(.title2)
                                .bold()
                            
                            Text("Comparte tu viaje y fluye")
                                .font(.title2)
                                .bold()
                            
                            Text("- Contaminación")
                                .font(.title2)
                                .bold()
                            Text("- Trafico")
                                .font(.title2)
                                .bold()
                            Text("+ Comodidad")
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()

                            
                    }
                    .foregroundColor(Color("white"))
                    
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
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .background(Color("blue_log_in"))
                .cornerRadius(10)
                
            }.padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        WelcomeView(showing: $show)
    }
}
