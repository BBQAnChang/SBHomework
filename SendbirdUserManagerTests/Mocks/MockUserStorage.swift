//
//  MockUserStorage.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import Foundation
import SendbirdUserManager

class MockUserStorage: SBUserStorage {
    private var cache = [String: SBUser]()
    private let queue = DispatchQueue(label: "com.SBUserstorage.queue", attributes: .concurrent)

    required init() {}

    func setUser(_ user: SBUser, for userId: String) {
        queue.async(flags: .barrier) {
            self.cache[userId] = user
        }
    }

    func getUsers() -> [SBUser] {
        var users = [SBUser]()
        
        queue.sync {
            users = Array(self.cache.values)
        }
        
        return users
    }

    func getUser(for userId: String) -> (SBUser)? {
        var user: (SBUser)?
        
        queue.sync {
            user = self.cache[userId]
        }
        
        return user
    }
}
