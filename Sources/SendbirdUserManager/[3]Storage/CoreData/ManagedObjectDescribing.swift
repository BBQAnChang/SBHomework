//
//  ManagedObjectDescribing.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation
import CoreData

protocol ManagedObjectDescribing where Self: NSManagedObject {
    associatedtype ServiceModel: ServiceModelDescribing

    static var entityName: String { get }
    var toModel: ServiceModel { get throws }
    func make(model: ServiceModel) throws
    func update(model: ServiceModel) throws
}
