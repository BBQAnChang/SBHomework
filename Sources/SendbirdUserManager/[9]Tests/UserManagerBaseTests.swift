//
//  UserManagerBaseTests.swift
//  SendbirdUserManager
//
//  Created by Sendbird
//

import Foundation
import XCTest

/// Unit Testing을 위해 제공되는 base test suite입니다.
/// 사용을 위해서는 해당 클래스를 상속받고,
/// `open func userManager() -> SBUserManager?`를 override한뒤, 본인이 구현한 SBUserManager의 인스턴스를 반환하도록 합니다.
open class UserManagerBaseTests: XCTestCase {
    open func userManager() -> SBUserManager? { UserManager() }

    public let applicationId = "72FC453A-FF67-40BB-8456-5FD9A424729D"   // Note: add an application ID
    public let apiToken = "d8a1c14683211557bb0a2d55b296c1460a1db1fd"        // Note: add an API Token

    public func testInitApplicationWithDifferentAppIdClearsData() throws {
        let userManager = try XCTUnwrap(self.userManager())
        
        // First init
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)    // Note: Add the first application ID and API Token

        let userId = UUID().uuidString
        let initialUser = UserCreationParams(userId: userId, nickname: "hello", profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        // Create 성공 "후" 캐싱이기 때문에 completion 타이밍에 테스트 하는것이 맞지 않나?
        // 테스트를 보아하니 요구조건을 조금 바꿔야하는 것으로 보임
        // Create 성공 "후" 캐싱이 아닌 요청 "후" 캐싱하고 실패시 제거하는것이 아닐까
        userManager.createUser(params: initialUser) { _ in
            // Check if the data exist
            let users = userManager.userStorage.getUsers()
            XCTAssertEqual(users.count, 1, "User should exist with an initial Application ID")

            // Second init with a different App ID
            userManager.initApplication(applicationId: "AppID2", apiToken: "Token2")    // Note: Add the second application ID and API Token

            // Check if the data is cleared
            let clearedUsers = userManager.userStorage.getUsers()
            XCTAssertEqual(clearedUsers.count, 0, "Data should be cleared after initializing with a different Application ID")
        }
    }

    // 유저 생성 테스트
    public func testCreateUser() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)
        
        let userId = UUID().uuidString
        let userNickname = UUID().uuidString
        let params = UserCreationParams(userId: userId, nickname: userNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let expectation = self.expectation(description: "Wait for user creation")
        
        userManager.createUser(params: params) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                XCTAssertEqual(user.nickname, userNickname)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    // 중복된 유저 생성 테스트
    public func testCreateDuplicatedUser() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId1 = UUID().uuidString
        let userNickname1 = UUID().uuidString

        let params1 = UserCreationParams(userId: userId1, nickname: userNickname1, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let params2 = UserCreationParams(userId: userId1, nickname: userNickname1, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for users creation")

        userManager.createUser(params: params1) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                XCTAssertEqual(user.id, userId1)
                userManager.createUser(params: params2) { result in
                    switch result {
                    case .success:
                        XCTFail("No Duplicated User")
                    case .failure(let error):
                        XCTAssertNotNil(error)
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // 유저 다수 생성 테스트
    public func testCreateUsers() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId1 = UUID().uuidString
        let userNickname1 = UUID().uuidString
        
        let userId2 = UUID().uuidString
        let userNickname2 = UUID().uuidString
        
        let params1 = UserCreationParams(userId: userId1, nickname: userNickname1, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let params2 = UserCreationParams(userId: userId2, nickname: userNickname2, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for users creation")
    
        userManager.createUsers(params: [params1, params2]) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users[0].nickname, userNickname1)
                XCTAssertEqual(users[1].nickname, userNickname2)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    // 중복 유저 다수 생성 테스트
    public func testCreateDuplicatedUsers() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId1 = UUID().uuidString
        let userNickname1 = UUID().uuidString

        let params1 = UserCreationParams(userId: userId1, nickname: userNickname1, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for users creation")

        userManager.createUsers(params: [params1, params1]) { result in
            switch result {
            case .failure(let error):
                guard let userManagerError = error as? UserManagerError else {
                    XCTFail("Failed with error: \(error)")
                    return
                }
                switch userManagerError {
                case let .createUsersFailed(users):
                    XCTAssertTrue(users.count == 1)
                default:
                    XCTFail("No createUsersFailed")
                }
            default:
                XCTFail("No Duplicated User")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // 유저 업데이트 테스트
    public func testUpdateUser() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId = UUID().uuidString
        let initialUserNickname = UUID().uuidString
        let updatedUserNickname = UUID().uuidString
        
        let initialParams = UserCreationParams(userId: userId, nickname: initialUserNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let updatedParams = UserUpdateParams(userId: userId, nickname: updatedUserNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for user update")
        
        userManager.createUser(params: initialParams) { creationResult in
            switch creationResult {
            case .success(_):
                userManager.updateUser(params: updatedParams) { updateResult in
                    switch updateResult {
                    case .success(let updatedUser):
                        XCTAssertEqual(updatedUser.nickname, updatedUserNickname)
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 유저 받아오기 테스트
    public func testGetUser() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId = UUID().uuidString
        let userNickname = UUID().uuidString
        
        let params = UserCreationParams(userId: userId, nickname: userNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for user retrieval")
        
        userManager.createUser(params: params) { creationResult in
            switch creationResult {
            case .success(let createdUser):
                userManager.getUser(userId: createdUser.userId) { getResult in
                    switch getResult {
                    case .success(let retrievedUser):
                        XCTAssertEqual(retrievedUser.nickname, userNickname)
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    // 유저 닉네임으로 받아오기 테스트
    public func testGetUsersWithNicknameFilter() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId1 = UUID().uuidString
        let userNickname1 = UUID().uuidString
        
        let userId2 = UUID().uuidString
        let userNickname2 = UUID().uuidString
        
        let params1 = UserCreationParams(userId: userId1, nickname: userNickname1, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let params2 = UserCreationParams(userId: userId2, nickname: userNickname2, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation = self.expectation(description: "Wait for users retrieval with nickname filter")
        
        userManager.createUsers(params: [params1, params2]) { creationResult in
            switch creationResult {
            case .success(_):
                userManager.getUsers(nicknameMatches: userNickname1) { getResult in
                    switch getResult {
                    case .success(let users):
                        XCTAssertEqual(users.count, 1)
                        XCTAssertEqual(users[0].nickname, userNickname1)
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 유저 복수 생성 최대값 테스트
    public func testCreateUsersLimit() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let users = (0..<11).map { UserCreationParams(userId: "user_id_\(UUID().uuidString)\($0)", nickname: "nickname_\(UUID().uuidString)\($0)", profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png") }

        let expectation = self.expectation(description: "Wait for users creation with limit")
        
        userManager.createUsers(params: users) { result in
            switch result {
            case .success(_):
                XCTFail("Shouldn't successfully create more than 10 users at once")
            case .failure(let error):
                // Ideally, check for a specific error related to the limit
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 유저 업데이트 레이스 컨디션 테스트
    public func testUpdateUserRaceCondition() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let userId = UUID().uuidString
        let initialUserNickname = UUID().uuidString
        let updatedUserNickname = UUID().uuidString
        
        let initialParams = UserCreationParams(userId: userId, nickname: initialUserNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
        let updatedParams = UserUpdateParams(userId: userId, nickname: updatedUserNickname, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")

        let expectation1 = self.expectation(description: "Wait for user update")
        let expectation2 = self.expectation(description: "Wait for user retrieval")
        
        userManager.createUser(params: initialParams) { creationResult in
            guard let createdUser = try? creationResult.get() else {
                XCTFail("Failed to create user")
                return
            }
            
            DispatchQueue.global().async {
                userManager.updateUser(params: updatedParams) { _ in
                    expectation1.fulfill()
                }
            }
            
            DispatchQueue.global().async {
                userManager.getUser(userId: createdUser.userId) { getResult in
                    if case .success(let user) = getResult {
                        XCTAssertTrue(user.nickname == initialUserNickname || user.nickname == updatedUserNickname)
                    } else {
                        XCTFail("Failed to retrieve user")
                    }
                    expectation2.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
    
    // 닉네임이 비어있을 경우 getUser 테스트
    public func testGetUsersWithEmptyNickname() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)

        let expectation = self.expectation(description: "Wait for users retrieval with empty nickname filter")
        
        userManager.getUsers(nicknameMatches: "") { result in
            if case .failure(let error) = result {
                // Ideally, check for a specific error related to the invalid nickname
                XCTAssertNotNil(error)
            } else {
                XCTFail("Fetching users with empty nickname should not succeed")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // 유저 단수 생성건에 RateLimit 테스트
    public func testRateLimitCreateUser() throws {
        let userManager = try XCTUnwrap(self.userManager())
        userManager.initApplication(applicationId: applicationId, apiToken: apiToken)
        
        // Concurrently create 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []
        
        for _ in 0..<11 {
            dispatchGroup.enter()
            let params = UserCreationParams(userId: UUID().uuidString, nickname: UUID().uuidString, profileURL: "https://cdn-icons-png.flaticon.com/128/4170/4170229.png")
            userManager.createUser(params: params) { result in
                results.append(result)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        // Assess the results
        let successResults = results.filter {
            if case .success = $0 { return true }
            return false
        }
        let rateLimitResults = results.filter {
            if case .failure(_) = $0 { return true }
            return false
        }

        XCTAssertEqual(successResults.count, 10)
        XCTAssertEqual(rateLimitResults.count, 1)
    }
}
