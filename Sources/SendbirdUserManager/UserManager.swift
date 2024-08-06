//
//  UserManager.swift
//  
//
//  Created by Sendbird
//

import Foundation

public typealias UserResult = Result<(SBUser), Error>
public typealias UsersResult = Result<[SBUser], Error>

/// Sendbird User Managent를 위한 SDK interface입니다.
public protocol SBUserManager {
    var networkClient: SBNetworkClient { get }
    var userStorage: SBUserStorage { get }
    
    /// Sendbird Application ID 및 API Token을 사용하여 SDK을 초기화합니다
    /// Init은 앱이 launching 될 때마다 불러야 합니다
    /// 만약 init의 sendbird application ID가 직전의 init에서 전달된 sendbird application ID와 다르다면 앱 내에 저장된 모든 데이터는 삭제되어야 합니다
    /// - Parameters:
    ///    - applicationId: Sendbird의 Application ID
    ///    - apiToken: 해당 Application에서 발급된 API Token
    func initApplication(applicationId: String, apiToken: String)
    
    /// UserCreationParams를 사용하여 새로운 유저를 생성합니다.
    /// Profile URL은 임의의 image URL을 사용하시면 됩니다
    /// 생성 요청이 성공한 뒤에 userStorage를 통해 캐시에 추가되어야 합니다
    /// - Parameters:
    ///    - params: User를 생성하기 위한 값들의 struct
    ///    - completionHandler: 생성이 완료된 뒤, user객체와 에러 여부를 담은 completion Handler
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?)
    
    /// UserCreationParams List를 사용하여 새로운 유저들을 생성합니다.
    /// 한 번에 생성할 수 있는 사용자의 최대 수는 10명로 제한해야 합니다
    /// Profile URL은 임의의 image URL을 사용하시면 됩니다
    /// 생성 요청이 성공한 뒤에 userStorage를 통해 캐시에 추가되어야 합니다
    /// - Parameters:
    ///    - params: User를 생성하기 위한 값들의 struct
    ///    - completionHandler: 생성이 완료된 뒤, user객체와 에러 여부를 담은 completion Handler
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?)
    
    /// 특정 User의 nickname 또는 profileURL을 업데이트합니다
    /// 업데이트 요청이 성공한 뒤에 캐시에 upsert 되어야 합니다 
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?)
    
    /// userId를 통해 특정 User의 정보를 가져옵니다
    /// 캐시에 해당 User가 있으면 캐시된 User를 반환합니다
    /// 캐시에 해당 User가 없으면 /GET API 호출하고 캐시에 저장합니다
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?)
    
    /// Nickname을 필터로 사용하여 해당 nickname을 가진 User 목록을 가져옵니다
    /// GET API를 호출하고 캐시에 저장합니다
    /// Get users API를 활용할 때 limit은 100으로 고정합니다
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?)
}

public final class UserManager: SBUserManager {
    public var networkClient: SBNetworkClient = Network()
    public let userStorage: SBUserStorage = UserStorage()
    
    private let queueProcessor = QueueProcessor<UserCreationParams>(maxQueueSize: UserManagerConstant.createMaxCount)

    public func initApplication(applicationId: String, apiToken: String) {
        if SBUserDefaults.appId != applicationId {
            userStorage.clear()
        }
        
        networkClient.appId = applicationId
        networkClient.apiToken = apiToken

        queueProcessor.stopProcessing()
    }

    public func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        do {
            try queueProcessor.enqueue(
                QueueProcessor.QueueItem(element: params) { [weak self] param in
                    guard let self else { return }
                    self.requestCreateUser(param: param) { userResult in
                        switch userResult {
                        case let .success(user):
                            completionHandler?(.success(user))
                        case let .failure(error):
                            completionHandler?(.failure(error))
                        }
                    }
                }
            )
        } catch {
            completionHandler?(.failure(error))
        }
    }

    public func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        requestCreateUserWithInterval(params: params, completionHandler: completionHandler)
    }

    public func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: API.UpdateUser(updateParams: params)) { [weak self] result in
            switch result {
            case let .success(response):
                self?.didSuccessUpsert(response, completionHandler: completionHandler)
            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }

    public func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
        } else {
            networkClient.request(request: API.GetUser(userId: userId)) { result in
                switch result {
                case let .success(response):
                    completionHandler?(.success(response.sbUser))
                case let .failure(error):
                    completionHandler?(.failure(error))
                }
            }
        }
    }

    public func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard nicknameMatches.isEmpty == false else {
            completionHandler?(.failure(UserManagerError.emptyNickname))
            return
        }

        networkClient.request(request: API.GetUsers(nickname: nicknameMatches, limit: 100)) { result in
            switch result {
            case let .success(response):
                completionHandler?(.success(response.users.map { $0.sbUser }))
            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }

    private func didSuccessUpsert(_ response: UserResponse, completionHandler: ((UserResult) -> Void)?) {
        let localUser = response.sbUser
        userStorage.upsertUser(localUser)
        completionHandler?(.success(localUser))
    }

    private func requestCreateUserWithInterval(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        let adjustedParams = Array(params.prefix(UserManagerConstant.createMaxCount))
        let interval = 1.0
       
        var failedUsers: [SBUser] = {
            if params.count > UserManagerConstant.createMaxCount {
                return Array(params.suffix(params.count - UserManagerConstant.createMaxCount))
                    .map { .init(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }
            } else {
                return []
            }
        }()

        var successUsers: [SBUser] = []
        let dispatchGroup = DispatchGroup()

        for (index, param) in adjustedParams.enumerated() {
            dispatchGroup.enter()

            // Schedule API request with delay
            DispatchQueue.global().asyncAfter(deadline: .now() + interval * Double(index)) { [weak self] in
                guard let self else { return }
                self.requestCreateUser(param: param) { result in
                    switch result {
                    case .success:
                        successUsers.append(.init(userId: param.userId, nickname: param.nickname, profileURL: param.profileURL))
                    case .failure:
                        failedUsers.append(.init(userId: param.userId, nickname: param.nickname, profileURL: param.profileURL))
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.wait()

        guard failedUsers.isEmpty else {
            completionHandler?(.failure(UserManagerError.createUsersFailed(failedUsers)))
            return
        }

        completionHandler?(.success(successUsers))
    }

    private func requestCreateUser(param: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: API.CreateUser(requestParam: param)) { [weak self] result in
            switch result {
            case let .success(response):
                self?.didSuccessUpsert(response, completionHandler: nil)
                completionHandler?(.success(response.sbUser))
            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }
}
