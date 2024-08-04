//
//  User+CoreDataClass.swift
//  
//
//  Created by 박종상 on 8/4/24.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    @NSManaged var nickname: String?
    @NSManaged var profileURL: String?
    @NSManaged var userId: String?
}
