//
//  GroupDetailsView.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI
import MapKit

struct GroupDetailsView: View {
    @Binding var group: GroupInfo
    @State var users = [User]()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 40.83834587046632,
            longitude: 14.254053016537693),
        span: MKCoordinateSpan(
            latitudeDelta: 0.03,
            longitudeDelta: 0.03)
        )
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 30) {
                HStack {
                    Text("Group: \(group.nombre)")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
                
                VStack{
                    HStack(alignment: .bottom) {
                        Text("Ubicación: ")
                            .bold()
                            .font(.subheadline)
                        
                        Text(group.direccion)
                        Spacer()
                    }
                    
                    Map(coordinateRegion: $region)
                        .frame(height: geo.size.height/2)
                        .cornerRadius(15)
                    
                    HStack(alignment: .bottom) {
                        Text("Miembros")
                            .bold()
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    ScrollView {
                        ForEach(users) { user in
                            HStack(alignment: .center) {
                                VStack(alignment: .leading) {
                                    Text("\(user.nombre) \(user.apellido)")
                                    Spacer()
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text(user.telefono)
                                            .font(.footnote)
                                    }
                                }
                                Spacer()
                                Image(systemName: "car.fill")
                            }
                            .padding()
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("gray_log_in"))
                            )
                            .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding()
            .onAppear() {
                Task {
                    if let tmp = await group.get_users() {
                        users = tmp
                    }
                }
            }
        }
    }
}

struct GroupDetailsView_Previews: PreviewProvider {
    @State static var group = GroupInfo.deft()
    static var previews: some View {
        GroupDetailsView(group: $group)
    }
}
