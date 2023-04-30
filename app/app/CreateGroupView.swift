//
//  CreateGroupView.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI

struct CreateGroupView: View {
    @State var nombre: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Crear grupo")
                    .bold()
                    .font(.title2)
                Spacer()
            }
            
            
            
            Spacer()
        }.padding()
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
