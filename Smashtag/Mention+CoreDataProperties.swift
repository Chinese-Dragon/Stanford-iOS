//
//  Mention+CoreDataProperties.swift
//  Smashtag
//
//  Created by Mark on 7/13/16.
//  Copyright © 2016 Mark. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mention {

    @NSManaged var keyword: String?
    @NSManaged var mentionCount: Int16
    @NSManaged var tweets: NSSet?

}
