//
//  GroupDetailsView.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import SwiftUI

struct GroupDetailsView: View {
    @Binding var group: GroupInfo
    
    var body: some View {
        VStack {
            Text("Group: \(group.nombre)")
        }
    }
}

struct GroupDetailsView_Previews: PreviewProvider {
    @State static var group = GroupInfo.deft()
    static var previews: some View {
        GroupDetailsView(group: $group)
    }
}
