//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 12/29/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
      return NSFetchRequest<Pin>(entityName: "Pin")
    }
    
   @NSManaged var latitude: Double
   @NSManaged var longitude: Double
   @NSManaged var photos: Set<Photo>
}

