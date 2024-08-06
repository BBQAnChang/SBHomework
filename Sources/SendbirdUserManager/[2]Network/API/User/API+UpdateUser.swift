//
//  API+UpdateUser.swift
//  
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

extension API {
    struct UpdateUser: Request {
        var method: NetworkMethod { .put }
        var path: String { "/users/\(updateParams.userId)" }
        var body: NetworkBody? { .json(object: updateParams) }
        
        private let updateParams: UserUpdateParams

        init(updateParams: UserUpdateParams) {
            self.updateParams = updateParams
        }

        func parse(_ data: Data) throws -> UserResponse {
            return try JSONDecoder().decode(UserResponse.self, from: data)
        }
    }
}
