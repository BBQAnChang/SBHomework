//
//  UserLocalProvider.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation
import CoreData

struct UserLocalProvider {
    typealias ManagedObjectsCompletion = UserCoreDataController<User>.ManagedObjectsCompletion
    typealias ManagedObjectCompletion = UserCoreDataController<User>.ManagedObjectCompletion
    typealias ServiceModelCompletion = UserCoreDataController<User>.ServiceModelCompletion
    typealias ServiceModelsCompletion = (Result<[SBUser], any Error>) -> Void

    enum FetchType {
        case id(String)
        case nickname(String)
        case all

        var predicate: NSPredicate? {
            switch self {
            case let .id(id):
                return NSPredicate(format: "userId == %@", id)
            case let .nickname(nickname):
                return NSPredicate(format: "nickname == %@", nickname)
            case .all:
                return nil
            }
        }
    }

    private let controller: UserCoreDataController<User>

    init(context: NSManagedObjectContext) {
        controller = .init(context: context)
    }

    func create(_ user: SBUser) throws {
        try controller.create(user)
    }

    func fetch(fetchType: FetchType) throws -> [SBUser] {
        let managedObjects = try controller.fetch(predicate: fetchType.predicate)
        let serviceModels = try managedObjects.compactMap { try $0.toModel }
        
        return serviceModels
    }

    func update(fetchType: FetchType, user: SBUser) throws {
        let managedObjects = try controller.fetch(predicate: fetchType.predicate)
        let managedObject = managedObjects.first
        try controller.update(from: managedObject, to: user)
    }

    func clear() throws {
        try controller.clear()
    }
}
