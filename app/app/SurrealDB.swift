//
//  SurrealDB.swift
//  app
//
//  Created by Alejandro D on 04/05/23.
//

import Foundation
import SwiftyJSON
import Semaphore

enum SurrealError: Error {
    case InvalidUrl, SessionError, Ok, No200Response(JSON, URLResponse)
}

protocol IntoJSON {
    func intoJSON() throws -> JSON
}

extension Data: IntoJSON {
    func intoJSON() throws -> JSON {
        try! JSON(data: self)
    }
}

struct Surreal {
    var address: String
    var auth: String?
    var connection: URLSessionWebSocketTask? = nil
    var state = SurrealState.Connecting
    var semaphore = AsyncSemaphore(value: 1)
    
    public mutating func start() async throws {
        try connect()
        let _ = try await use(namespace: "proyecto_ios", database: "proyecto")
    }

    public mutating func reset_auth() {
        auth = nil
    }

    public mutating func connect() throws {
        guard let url = URL(string: "ws://\(address)/rpc") else {
            throw SurrealError.InvalidUrl
        }

        connection = URLSession.shared.webSocketTask(with: url)
        connection?.resume()
        state = SurrealState.Connected
    }

    public mutating func stop() {
        connection?.cancel(with: .goingAway, reason: nil)
        state = SurrealState.Disconnected
    }
    
    public mutating func query(_ sql: String) async throws -> Response {
        return try await _send_recv(req: Request(id: UUID().uuidString.lowercased(), method: "query", params: try! JSONEncoder().encode([sql]).intoJSON()))
    }

    public mutating func invalidate() async throws -> Response {
        return try await _send_recv(req: Request(id: UUID().uuidString.lowercased(), method: "invalidate", params: JSON()))
    }

    public mutating func use(namespace: String, database: String) async throws -> Response {
        return try await _send_recv(req: Request(id: UUID().uuidString.lowercased(), method: "use", params: try! JSONEncoder().encode([namespace, database]).intoJSON()))
    }

    private func post(endpoint: String) throws -> URLRequest {
        guard let url = URL(string: "http://\(address)/\(endpoint)") else {
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

    public mutating func authenticate() async throws -> Response {
        guard let auth = auth else {
            throw SurrealError.SessionError
        }
    
        return try await _send_recv(req: Request(id: UUID().uuidString.lowercased(), method: "authenticate", params: try! JSONEncoder().encode([auth]).intoJSON()))
    }

    public mutating func _send(req: Request) async throws {
        guard let connection = connection else {
            throw SurrealError.SessionError
        }

        let req_str = req.into_string()
        try await connection.send(.string(req_str))
    }

    public mutating func _recv(for_id: String) async throws -> Response {
        guard let connection = connection else {
            throw SurrealError.SessionError
        }

        // TODO: add error if key "error"
        // See https://github.com/surrealdb/surrealdb.py/blob/main/surrealdb/ws.py#LL709C1-LL710C1
        let res = try await connection.receive()
        switch res {
            case .string(let str):
                print(res)
                return try JSONDecoder().decode(Response.self, from: str.data(using: String.Encoding.utf8)!)
            default:
                throw SurrealError.SessionError
        }
    }

    public mutating func _send_recv(req: Request) async throws -> Response {
        print("waiting")
        await semaphore.wait()
        print("starting")
            try await _send(req: req)
            let res = try await _recv(for_id: req.id)
        let _ = semaphore.signal()
        print("done")
        print(req)
        print(res)
        return res
    }
}

enum SurrealState {
    case Disconnected, Connected, Authenticated, Connecting
}

struct Request: Codable {
    var id: String
    var method: String
    var params: JSON

    func into_string() -> String {
        try! JSONEncoder().encode(self).intoJSON().description
    }
}

struct Response: Codable {
    var id: String
    var result: JSON
    var json: JSON {
        result[0]["result"]
    }
}
