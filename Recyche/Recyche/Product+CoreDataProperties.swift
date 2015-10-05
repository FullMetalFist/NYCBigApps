//
//  Product+CoreDataProperties.swift
//  Recyche
//
//  Created by Zel Marko on 05/10/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var name: String?
    @NSManaged var material: String?
    @NSManaged var numberOfScans: NSNumber?
    @NSManaged var image: NSObject?

}
