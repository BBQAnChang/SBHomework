//
//  UserStorage.swift
//  
//
//  Created by Sendbird
//

import Foundation

/// Sendbird User 를 관리하기 위한 storage class입니다
public protocol SBUserStorage {
    /// 해당 User를 저장 또는 업데이트합니다
    func upsertUser(_ user: SBUser)
    
    /// 현재 저장되어있는 모든 유저를 반환합니다
    func getUsers() -> [SBUser]
    /// 현재 저장되어있는 유저 중 nickname을 가진 유저들을 반환합니다
    func getUsers(for nickname: String) -> [SBUser]
    /// 현재 저장되어있는 유저들 중에 지정된 userId를 가진 유저를 반환합니다.
    func getUser(for userId: String) -> (SBUser)?

    func clear()
}

public struct UserStorage: SBUserStorage {
    private let provider: UserLocalProvider
    private let locker = NSRecursiveLock()

    init() {
        UserCoreData.shared.configure()
        provider = UserLocalProvider(context: UserCoreData.shared.newBackgroundContext)
    }

    public func upsertUser(_ user: SBUser) {
        locker.lock()

        do {
            let users = try provider.fetch(fetchType: .id(user.userId))

            if users.isEmpty {
                try provider.create(user)
            } else {
                try provider.update(fetchType: .id(user.userId), user: user)
            }
        } catch {
            debugPrint(error)
        }

        locker.unlock()
    }
    
    public func getUsers() -> [SBUser] {
        defer {
            locker.unlock()
        }
        locker.lock()

        do {
            return try provider.fetch(fetchType: .all)
        } catch {
            return []
        }
    }
    
    public func getUsers(for nickname: String) -> [SBUser] {
        defer {
            locker.unlock()
        }
        locker.lock()

        do {
            return try provider.fetch(fetchType: .nickname(nickname))
        } catch {
            return []
        }
    }
    
    public func getUser(for userId: String) -> (SBUser)? {
        defer {
            locker.unlock()
        }
        locker.lock()
        
        do {
            return try provider.fetch(fetchType: .id(userId)).first
        } catch {
            return nil
        }
    }

    public func clear() {
        
    }
}
