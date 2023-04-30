//
//  dataStructures.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import Foundation

struct GroupCreation: Codable {
    var nombre: String = ""
    var destination: String = ""
    var puntuacion: Float = 4.5
    var id_owner: Int64 = 0
    
    mutating func create_group(id: Int64) async -> Bool {
        id_owner = id
        
        let url = URL(string: "http://54.86.117.228:9090/new_group")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = try? JSONEncoder().encode(self) {
            req.httpBody = body
        } else { return false }
        
        if let (_, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse!.statusCode == 200 {
                return true
            }
        }
        
        return false
        
    }
}

struct GroupInfo: Codable, Identifiable, Equatable {
    var id: Int64 {
        id_grupo
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    var id_conductor: Int32
    var puntuacion_min: Float
    var id_grupo: Int64
    var id_owner: Int32
    var direccion: String
    var nombre: String
    
    static func deft() -> GroupInfo {
        GroupInfo(id_conductor: 0, puntuacion_min: 0, id_grupo: 0, id_owner: 0, direccion: "", nombre: "")
    }
    
    static func group_info(id: Int64) async -> GroupInfo? {
        let url = URL(string: "http://54.86.117.228:9090/group/\(id)")!
        if let (data, _) = (try? await URLSession.shared.data(from: url) ) {
            let info = try? JSONDecoder().decode(GroupInfo.self, from: data)
            return info
        }
        
        return nil
    }
    
    func get_users() async -> [User]? {
        let url = URL(string: "http://54.86.117.228:9090/users_of/\(id)")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        if let (data, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse!.statusCode == 200 {
                return try! JSONDecoder().decode([User].self, from: data)
            }
        }
        return nil
    }
}

struct UserLoginInfo: Encodable {
    var correo: String
    var password: String
    
    static func login(user: String, pass: String) async -> User? {
        let url = URL(string: "http://54.86.117.228:9090/login")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = UserLoginInfo(correo: user, password: pass)
        if let body = try? JSONEncoder().encode(user) {
            req.httpBody = body
        } else { return nil }
        
        if let (data, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse!.statusCode == 202 {
                return try! JSONDecoder().decode(User.self, from: data)
            }
        }
        
        return nil
    }
}

struct User: Codable, Identifiable {
    var id: Int64 = 0
    var nombre: String = ""
    var apellido: String = ""
    var fecha_nacimiento: String = ""
    var correo: String = "DEFAULT"
    var puntuacion: Float = 0.0
    var telefono: String = ""
    var licencia: String? = nil
    var password: String = ""
    var numero_de_viajes: Int64 = 0
    var calificacion_conductor: Float = 0.0
    var activo: Bool = false
    
    func get_groups() async -> [GroupInfo]? {
        let url = URL(string: "http://54.86.117.228:9090/groups_of/\(id)")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        if let (data, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse!.statusCode == 200 {
                return try! JSONDecoder().decode([GroupInfo].self, from: data)
            }
        }
        return nil
    }
    
    func is_default() -> Bool {
        correo == "DEFAULT"
    }
}

struct UserRegister: Codable {
    var nombre: String = ""
    var apellido: String = ""
    var fecha_nacimiento: String = ""
    var correo: String = ""
    var telefono: String = ""
    var password: String = ""
    
    // Returns an string when it fails
    func register() async -> String? {
        let url = URL(string: "http://54.86.117.228:9090/register")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if dateFormatter.date(from: self.fecha_nacimiento) == nil {
            return "Fecha invalida: formato yyyy-MM-dd"
        }
        
        if let body = try? JSONEncoder().encode(self) {
            req.httpBody = body
        } else { return "Error al serializar" }
        
        if let (_, response) = (try? await URLSession.shared.data(for: req) ) {
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 201 {
                return nil
            } else if httpResponse?.statusCode == 302 {
                return "El usuario existe"
            }
        } else {
            return "Error al obtener"
        }
        
        return "Error"
    }
}


