//
//  Product.swift
//  Recyche
//
//  Created by Zel Marko on 05/10/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import Foundation
import CoreData

class Product: NSManagedObject {
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, _name: String, _material: String, _numberOfScans: NSNumber) -> Product {
        let newProduct = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: moc) as! Product
        
        newProduct.name = _name
        newProduct.material = _material
        newProduct.numberOfScans = _numberOfScans
        
        return newProduct
    }
}
