//
//  User+Extension.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation
import CoreData

extension User: ManagedObjectDescribing {
    static var entityName: String { "User" }

    var toModel: SBUser {
        get throws {
            guard let userId = userId else {
                throw UserCoreDataError.convertFailed
            }

            return SBUser(userId: userId, nickname: nickname, profileURL: profileURL)
        }
    }

    func make(model: SBUser) throws {
        userId = model.userId
        nickname = model.nickname
        profileURL = model.profileURL
    }

    func update(model: SBUser) throws {
        nickname = model.nickname
        profileURL = model.profileURL
    }
}
