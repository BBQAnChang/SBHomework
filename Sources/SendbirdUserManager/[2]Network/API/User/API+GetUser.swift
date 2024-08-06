//
//  API+GetUser.swift
//  
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

extension API {
    struct GetUsers: Request {
        struct Response: Decodable {
            let users: [UserResponse]
        }

        var method: NetworkMethod { .get }
        var path: String { "/users" }
        var parameters: [String : Any] { ["nickname": nickname] }

        private let nickname: String

        init(nickname: String) {
            self.nickname = nickname
        }

        func parse(_ data: Data) throws -> Response {
            return try JSONDecoder().decode(Response.self, from: data)
        }
    }

    struct GetUser: Request {
        var method: NetworkMethod { .get }
        var path: String { "/users/\(userId)" }

        private let userId: String

        init(userId: String) {
            self.userId = userId
        }

        func parse(_ data: Data) throws -> UserResponse {
            return try JSONDecoder().decode(UserResponse.self, from: data)
        }
    }
}
