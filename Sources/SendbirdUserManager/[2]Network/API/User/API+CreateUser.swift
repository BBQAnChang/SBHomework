//
//  API+CreateUser.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

extension API {
    struct CreateUser: Request {
        var method: NetworkMethod { .post }
        var path: String { "/users" }
        var body: NetworkBody? { nil }

        private let requestParam: UserCreationParams

        init(requestParam: UserCreationParams) {
            self.requestParam = requestParam
        }

        func parse(_ data: Data) throws -> UserResponse {
            return try JSONDecoder().decode(UserResponse.self, from: data)
        }
    }
}
