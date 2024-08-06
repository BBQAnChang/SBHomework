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
            struct User: Decodable {
                enum CodingKeys: String, CodingKey {
                    case userId = "user_id"
                    case nickname
                    case profileURL = "profile_url"
                }

                let userId: String
                let nickname: String
                let profileURL: String?
            }

            let users: [User]
        }

        var method: NetworkMethod { .get }
        var path: String { "/users" }
    }

    struct GetUser: Request {
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

        var method: NetworkMethod { .get }
        var path: String { "/users/\(userId)" }

        private let userId: String

        init(userId: String) {
            self.userId = userId
        }
    }
}
