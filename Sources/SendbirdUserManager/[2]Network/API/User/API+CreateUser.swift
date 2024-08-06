//
//  API+CreateUser.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

extension API {
    struct CreateUser: Request {
        struct Response: Decodable {
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case nickname
                case profileURL = "profile_url"
            }

            let userId: String
            let nickname: String
            let profileURL: String?
        }

        var method: NetworkMethod { .post }
        var path: String { "/users" }
        var body: NetworkBody? { nil }

        private let requestParam: UserCreationParams

        init(requestParam: UserCreationParams) {
            self.requestParam = requestParam
        }
    }
}
