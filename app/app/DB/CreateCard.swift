//
//  CreateCard.swift
//  app
//
//  Created by iOS Lab on 31/05/23.
//

import SwiftUI

struct CreateCard: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var client: Surreal
    @Binding var collection: Collection
    @State var cardName: String = ""
    @State var answer: String = ""
    
    var body: some View {
        
        VStack{
            
            
            HStack{
                Text("Añade una Pregunta").font(.title3).bold()
                Spacer()
            }.padding()
            HStack{
                TextField("Escribe una pregunta", text: $cardName)
                Spacer()
            }.padding()
            
            HStack{
                Text("Añade una Respuesta").font(.title3).bold()
                Spacer()
            }.padding()
            HStack{
                TextField("Escribe la respuesta", text: $answer)
                Spacer()
            }.padding()
            
            Button("Create") {
                Task {
                    let _ = try? await client.query("""
                        UPDATE \(collection.id) SET add_card = {
                            front: "\(cardName)",
                            back: "\(answer)"
                        };
                    """)
                    presentationMode.wrappedValue.dismiss();
                }
            }
            
            Spacer()
        }
        .navigationTitle("new card").padding()
    }
}


