//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 12/29/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import CoreData

extension Pin {
   @NSManaged var latitude: Double
   @NSManaged var longitude: Double
   @NSManaged var photo: Set<Photo>
}

