//
//  SurrealDB.swift
//  app
//
//  Created by Alejandro D on 04/05/23.
//

import Foundation
import SwiftyJSON

enum SurrealError: Error {
    case InvalidUrl, SessionError, Ok, No200Response(JSON, URLResponse)
}

struct Response {
    let result: [[String: Any]]
    let status: String
    let time: String
}

protocol IntoJSON {
    func intoJSON() throws -> JSON
}

extension Data: IntoJSON {
    func intoJSON() throws -> JSON {
        try! JSON(data: self)
    }
}

protocol IntoResponse {
    func fetchAll() throws -> [Response]
    func fetchOne() throws -> Response?
}

extension Data: IntoResponse {
    func fetchAll() throws -> [Response] {
        let json = try! JSONSerialization.jsonObject(with: self, options: []) as! [[String: Any]]
        return json.map({ Response(result: $0["result"] as! [[String: Any]], status: $0["status"] as! String, time: $0["time"] as! String)})
    }

    func fetchOne() throws -> Response? {
        try self.fetchAll().first
    }
}

struct SurrealDBClient {
    var url: String
    var auth: String?
    
    public mutating func reset_auth() {
        auth = nil
    }
    
    private func post(endpoint: String) throws -> URLRequest {
        guard let url = URL(string: "\(url)/\(endpoint)") else {
            throw SurrealError.InvalidUrl
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("proyecto_ios", forHTTPHeaderField: "NS")
        req.addValue("proyecto", forHTTPHeaderField: "DB")
        req.addValue("account", forHTTPHeaderField: "SC")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return req;
    }

    public mutating func register(mail: String, user: String, pass: String) async throws -> String? {
        var req = try! post(endpoint: "signup")
        
        req.httpBody = #"""
        {
          "NS": "proyecto_ios",
          "DB": "proyecto",
          "SC": "account",
          "email": "\#(mail)",
          "pass": "\#(pass)",
          "user": "\#(user)"
        }
        """#.data(using: String.Encoding.utf8)

        guard let (data, res) = try? await URLSession.shared.data(for: req) else {
            throw SurrealError.SessionError
        }
  
        if (res as? HTTPURLResponse)?.statusCode != 200 {
            throw SurrealError.No200Response(try! JSON(data: data), res)
        }

        let json = try! JSON(data: data)
        auth = json["token"].stringValue
        return auth
    }

    public mutating func login(mail: String, pass: String) async throws -> String? {
        var req = try! post(endpoint: "signin")

        req.httpBody = #"""
        {
          "NS": "proyecto_ios",
          "DB": "proyecto",
          "SC": "account",
          "email": "\#(mail)",
          "pass": "\#(pass)"
        }
        """#.data(using: String.Encoding.utf8)

        guard let (data, res) = try? await URLSession.shared.data(for: req) else {
            throw SurrealError.SessionError
        }

        if (res as? HTTPURLResponse)?.statusCode != 200 {
            throw SurrealError.No200Response(try! JSON(data: data), res)
        }

        let json = try! JSON(data: data)
        auth = json["token"].stringValue
        return auth
    }

    func exec(_ query: String) async throws -> Data {
        guard let auth = auth else {
            throw SurrealError.InvalidUrl
        }
        
        var req = try! post(endpoint: "sql")
        req.addValue("Bearer \(auth)", forHTTPHeaderField: "Authorization")
        req.httpBody = query.data(using: String.Encoding.utf8)

        guard let (data, res) = try? await URLSession.shared.data(for: req) else {
            throw SurrealError.SessionError
        }

        if (res as? HTTPURLResponse)?.statusCode != 200 {
            throw SurrealError.No200Response(try! JSON(data: data), res)
        }

        return data
    }

    func server_is_healthy() async throws -> Bool {
        guard let url = URL(string: "\(url)/health") else {
            throw SurrealError.InvalidUrl
        }

        guard let (_, res) = try? await URLSession.shared.data(from: url) else {
            throw SurrealError.SessionError
        }

        return (res as? HTTPURLResponse)?.statusCode == 200
    }
}

