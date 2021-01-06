//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/1/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
      return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
   @NSManaged var image: NSData
   @NSManaged var createdDate: NSDate
   @NSManaged var pins: Set<Pin>
}
