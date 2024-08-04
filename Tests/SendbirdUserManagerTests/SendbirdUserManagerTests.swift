//
//  SendbirdUserManagerTests.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import XCTest
@testable import SendbirdUserManager

final class UserManagerTests: UserManagerBaseTests {
    override func userManager() -> SBUserManager {
        UserManager()
    }
}

final class UserStorageTests: UserStorageBaseTests {
    override func userStorage() -> SBUserStorage? {
        UserStorage()
    }
}

//final class NetworkClientTests: NetworkClientBaseTests {
//    override func networkClient() -> SBNetworkClient? {
//        MockNetworkClient()
//    }
//}
