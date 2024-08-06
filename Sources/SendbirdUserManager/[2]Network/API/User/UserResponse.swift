//
//  UserResponse.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

struct UserResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case profileURL = "profile_url"
    }

    let userId: String
    let nickname: String
    let profileURL: String?
}

extension UserResponse {
    var sbUser: SBUser {
        SBUser(userId: userId, nickname: nickname, profileURL: profileURL)
    }
}
