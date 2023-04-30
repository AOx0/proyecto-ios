//
//  dataStructures.swift
//  app
//
//  Created by iOS Lab on 30/04/23.
//

import Foundation

struct GroupInfo: Codable {
    var id_conductor: Int32
    var automovil: Int64
    var puntuacion_min: Int64
    var id_grupo: Int64
    var id_owner: Int32
    var direccion: String
    var nombre: String
    
    static func group_info(id: Int64) async -> GroupInfo? {
        let url = URL(string: "https://65ba-192-100-230-250.ngrok.io/group/\(id)")!
        if let (data, _) = (try? await URLSession.shared.data(from: url) ) {
            let info = try? JSONDecoder().decode(GroupInfo.self, from: data)
            return info
        }
        
        return nil
    }
}

struct UserLoginInfo: Encodable {
    var correo: String
    var password: String
    
    static func login(user: String, pass: String) async -> User? {
        let url = URL(string: "https://65ba-192-100-230-250.ngrok.io/login")!
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

struct User: Codable {
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
    
    func is_default() -> Bool {
        correo == "DEFAULT"
    }
}

struct UserRegister: Codable {
    var nombre: String = "DEFAULT"
    var apellido: String = ""
    var fecha_nacimiento: String = ""
    var correo: String = ""
    var telefono: String = ""
    var password: String = ""
    
    // Returns an string when it fails
    func register() async -> String? {
        let url = URL(string: "https://65ba-192-100-230-250.ngrok.io/register")!
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


