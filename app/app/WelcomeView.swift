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
