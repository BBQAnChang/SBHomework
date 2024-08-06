//
//  UserCoreDataController.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation
import CoreData

struct UserCoreDataController<M: ManagedObjectDescribing> {
    typealias ManagedObjectsCompletion = (Result<[M], any Error>) -> Void
    typealias ManagedObjectCompletion = (Result<M, any Error>) -> Void
    typealias ServiceModelCompletion = (Result<ServiceModelDescribing, any Error>) -> Void

    let context: NSManagedObjectContext
}

extension UserCoreDataController {
    // Create
    func create(_ serviceModel: ServiceModelDescribing) throws {
        try context.performAndWait {
            guard
                let serviceModel = serviceModel as? M.ServiceModel,
                let entityDescription = NSEntityDescription.entity(forEntityName: M.entityName, in: context)
            else {
                return
            }
            
            let managedObject = M(entity: entityDescription, insertInto: context)
            try managedObject.make(model: serviceModel)
            try context.save()
        }
    }

    // Read
    func fetch(predicate: NSPredicate?) throws -> [M] {
        let request = NSFetchRequest<M>(entityName: M.entityName)
        request.predicate = predicate

        return try context.performAndWait {
            let managedObjects = try context.fetch(request)
            return managedObjects
        }
    }

    // Update
    func update(from object: M?, to model: ServiceModelDescribing) throws {
        try context.performAndWait {
            guard let model = model as? M.ServiceModel else { return }

            try object?.update(model: model)
            try context.save()
        }
    }

    // Delete
    func delete(_ object: M) throws {
        try context.performAndWait {
            context.delete(object)
            try context.save()
        }
    }

    // Clear
    func clear() throws {
        try context.performAndWait {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: M.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            deleteRequest.resultType = .resultTypeStatusOnly

            if let _ = try context.execute(deleteRequest) as? NSBatchDeleteResult {
                try context.save()
            }
        }
    }
}
