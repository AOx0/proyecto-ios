//
//  DataStructs.swift
//  app
//
//  Created by Alejandro D on 22/05/23.
//

import Foundation
import SwiftyJSON

struct User {
    var id: String = ""
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var gravatar: String = ""
    var gravatar_md5: String = ""
    var following: Bool = false
    var num_following: UInt64 = 0
    var num_followers: UInt64 = 0
    var own_collections = [Collection]()
    var sus_collections = [Collection]()
    var rec_collections = [Collection]()
    var search_collections = [[Collection](), [Collection](), [Collection]()]


    
    public mutating func load_user(for_id: String, client: inout Surreal) async {
        guard let info = try? await client.query("SELECT *, fn::is_following(id) FROM \(for_id)").json[0] else {
            return
        }
        
        id = info["id"].stringValue
        email = info["email"].stringValue
        first_name = info["first_name"].stringValue
        last_name = info["last_name"].stringValue
        gravatar = info["gravatar"].stringValue
        gravatar_md5 = info["gravatar_md5"].stringValue
        num_followers = info["num_followers"].uInt64Value
        num_following = info["num_following"].uInt64Value
        following = info["fn::is_following"].boolValue
    }
    
    public mutating func reset() {
        self = User()
    }
}

struct Collection: Equatable {
    var id: String
    var name: String
    var author: String
    var description: String
    var pub: Bool
    var views: UInt64
    var sus: UInt64
    var user_owned = false
    var is_suscribed = false
    var cards: [Card] = [Card]()

    static func load_collection(from_json info: JSON, issuer: inout User) -> Collection {
        return Collection(
            id: info["id"].stringValue,
            name: info["name"].stringValue,
            author: info["author"].stringValue,
            description: info["description"].stringValue,
            pub: info["public"].boolValue,
            views: info["num_views"].uInt64Value,
            sus: info["num_sus"].uInt64Value,
            user_owned: issuer.id == info["author"].stringValue,
            is_suscribed: info["is_sus"].boolValue
        )
    }

    @discardableResult
    mutating func load_cards(client: inout Surreal) async -> Bool {
        guard let response = try? await client.query("SELECT VALUE out.* FROM \(id)->stack").json else {
            return false
        }
        
        cards = response.arrayValue.map() { info in
            Card(
                id: info["id"].stringValue,
                collection_id: info["collection"].stringValue,
                back: info["back"].stringValue,
                front: info["front"].stringValue
            )
        }
        
        return true
    }
}

struct Card: Equatable {
    var id: String
    var collection_id: String
    var back: String
    var front: String
}
