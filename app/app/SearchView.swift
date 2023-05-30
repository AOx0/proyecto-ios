//
//  SearchView.swift
//  app
//
//  Created by Alejandro D on 06/05/23.
//

import SwiftUI


struct SearchView: View {
    @Binding var client: Surreal
    @Binding  var user: User
    @State var search = ""
    @State var estado = false
    var names = ["User Name", "Tag", "Collections"]
    @State var is_active = [false, false, false]
    
  


    var body: some View {
     
            VStack{
               
               
                    TextField("Search by ...",text: $search) .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder).onChange(of: search){
                            query in Task{
                                guard let res = try? await client.query("select *, fn::is_sus(id) from array::distinct(array::flatten((SELECT * FROM (SELECT VALUE id FROM user WHERE type::string(id) ~ '\(search)')->owns->collection)))").json else {
                                    return
                                }
                                user.search_collections[0] = res.arrayValue.map() { col in
                                    Collection.load_collection(from_json: col, issuer: &user)
                                }
                                
                                
                                guard let res2 = try? await client.query("select *, fn::is_sus(id) from array::distinct(array::flatten((SELECT * FROM (SELECT VALUE id FROM tag WHERE type::string(id) ~ '\(search)')<-tagged<-collection)))").json else{
                                    return
                                }
                                user.search_collections[1] = res2.arrayValue.map() { col2 in
                                    Collection.load_collection(from_json: col2, issuer: &user)
                                }
                                
                                
                                guard let res3 = try? await client.query("select *, fn::is_sus(id) from array::distinct(array::flatten((select value id from collection where name ?~ '\(search)')))").json else {
                                    return
                                }
                                user.search_collections[2] = res3.arrayValue.map() { col3 in
                                    Collection.load_collection(from_json: col3, issuer: &user)
                                }
                            }
                        }
                
              
                if (search != ""){
                    ScrollView{
                        ForEach(0..<user.search_collections.filter({
                            e in !e.isEmpty
                        }).count, id: \.self){i in
                            VStack{
                                Divider()
                                HStack{
                                    Text(names[i]).font(.title3).bold().onTapGesture {
                                        is_active[i].toggle()
                                    }.fullScreenCover(isPresented: $is_active[i], content: {
                                        search_user(titulo : names[i],client: $client, user: $user, id: i)
                                    })
                                    Spacer()
                                }.padding()
                                
                                coll(client: $client, user: $user, i: i)
                            }
                            
                        }
                        
                    }
                }
                Text("")
        }
    }
}



struct search_user : View{
    @Environment(\.presentationMode) var presentationMode
    var titulo:String
    @Binding var client: Surreal
    @Binding  var user: User
    var id:Int
    

    var body: some View {
        
        VStack {
            HStack{
                Spacer()
                Button(action:{self.presentationMode.wrappedValue.dismiss()}) {
                    Image(systemName: "xmark").foregroundColor(.black)
                }
                
            }.padding()
            ScrollView {
                    ForEach(user.search_collections[id], id: \.self.id) { collection in
                        CardView(
                            collection: $user.search_collections[id][user.search_collections[id].firstIndex(of: collection)!],
                            client: $client,
                            other_user: $user,
                            user: $user
                        )
                    }
            }
            
        }.padding()
        
    }
    
}

struct coll : View{
    @Binding var client: Surreal
    @Binding  var user: User
    var i:Int
    var body: some View {
            ForEach(user.search_collections[i], id: \.self.id) { collection in
                CardView(
                    collection: $user.search_collections[i][user.search_collections[i].firstIndex(of: collection)!],
                    client: $client,
                    other_user: $user,
                    user: $user
                )
            }
        
    }
}
