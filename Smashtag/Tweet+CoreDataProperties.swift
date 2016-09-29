//
//  Tweet+CoreDataProperties.swift
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

extension Tweet {

    @NSManaged var posted: Date?
    @NSManaged var text: String?
    @NSManaged var unique: String?
    @NSManaged var mentions: NSSet?
    @NSManaged var tweeter: TwitterUser?

}
