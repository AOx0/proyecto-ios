//
//  CreateCollection.swift
//  app
//
//  Created by Alejandro D on 05/05/23.
//

import SwiftUI

struct CreateCollection: View {
    @Environment(\.dismiss) var dismiss
    @State var currentView: Binding<Int>
    
    // @State var collectionType = 0
    @State var collectionName: String = ""
    @State var tags: String = ""
    @State var isPublic: Bool = false
    
    var body: some View {
        Group {
            GeometryReader { geo in
                VStack(spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("Collection Name")
                            .font(.headline)
                        
                        TextField("My collection", text: $collectionName)
                    }.frame(width: geo.size.width)
                    
                    VStack(alignment: .leading) {
                        Toggle("Public Collection", isOn: $isPublic)
                            .font(.headline)
                        
                        Text("Note: Other users can see and suscribe to your collection if public.")
                            .font(.footnote)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .frame(width: geo.size.width)
                    
                    Spacer()
                    
                    Button("Create") {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Create Collection")
        .padding()
    }
}
