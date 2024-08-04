//
//  UserCoreData.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation
import CoreData

final class UserCoreData {
    static let shared = UserCoreData()

    private var container: NSPersistentContainer?

    var newBackgroundContext: NSManagedObjectContext {
        guard let backgroundContext = container?.newBackgroundContext() else {
            fatalError("Cannot Create CoreDataContainer's BackgroundContext")
        }

        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.automaticallyMergesChangesFromParent = true
        return backgroundContext
    }

    func configure() {
        guard
            let momd = Bundle.module.url(forResource: "User", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: momd)
        else {
            return
        }

        let container = NSPersistentContainer(name: "User", managedObjectModel: mom)
        let description = NSPersistentStoreDescription()
        container.persistentStoreDescriptions = [description]

        if let persistentStore = container.persistentStoreDescriptions.first {
            persistentStore.timeout = 30
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.shouldDeleteInaccessibleFaults = true

        self.container = container
        self.container?.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

extension UserCoreData {

}
