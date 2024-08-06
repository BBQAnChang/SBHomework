//
//  API+UpdateUser.swift
//  
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

extension API {
    struct UpdateUser: Request {
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

        var method: NetworkMethod { .put }
        var path: String { "/users/\(userId)" }
        var body: NetworkBody? { .json(object: updateParams) }

        private let userId: String
        private let updateParams: UserUpdateParams

        init(userId: String, updateParams: UserUpdateParams) {
            self.userId = userId
            self.updateParams = updateParams
        }
    }
}
