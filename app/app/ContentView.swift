//
//  ContentView.swift
//  0243179_projecto
//
//  Created by iOS Lab on 29/04/23.
//

import SwiftUI

struct ContentView: View {
    @State var show_welcome: Bool = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State var user: User = User()
    
    
    var body: some View {
        NavigationView {
            if !user.is_default() {
                HomeView(user: $user)
            } else {
                ZStack{
                    WelcomeView(showing: $show_welcome)
                        .opacity(show_welcome ? 1 : 0)
                        .animation(.easeOut, value: show_welcome)
                        .zIndex(2)
                    LoginView(global_user: $user)
                        .zIndex(1)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
