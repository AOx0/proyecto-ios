//
//  ContentView.swift
//  0243179_projecto
//
//  Created by iOS Lab on 29/04/23.
//

import SwiftUI

struct ContentView: View {
    @State private var login = false
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Color("blue_principal").ignoresSafeArea()
                VStack{
                    HStack{
                        Text("NOMBRE").bold().font(.largeTitle).foregroundColor(Color("white"))
                        Spacer()
                    }
                    Spacer()
                    
                    HStack{
                        Text("¿ Por qué usar ?").font(.title2).bold().foregroundColor(Color("white"))
                        Spacer()
                    }
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                       
                        HStack(alignment: .center){
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: (geo.size.width)*10/13, height:geo.size.height/10).foregroundColor(Color("blue_log_in"))
                                Button(action: { login = true }) {
                                    Text("Login").font(.title)
                                    }
                                NavigationLink("", destination: Login() , isActive: $login)
                                
                            
                              
                            }
    
                            
                        }
                    
                    
                }.padding()
                
                
            }
        }
    
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
