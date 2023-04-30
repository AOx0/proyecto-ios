//
//  ContentView.swift
//  0243179_projecto
//
//  Created by iOS Lab on 29/04/23.
//

import SwiftUI

struct ContentView: View {
    @State var show_welcome: Bool = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    
    var body: some View {
        NavigationView {
            ZStack{
                WelcomeView(showing: $show_welcome)
                    .opacity(show_welcome ? 1 : 0)
                    .animation(.easeOut, value: show_welcome)
                    .zIndex(2)
                LoginView()
                    .zIndex(1)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
