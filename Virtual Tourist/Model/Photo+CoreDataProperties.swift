//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/1/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import Foundation

extension Photo {
    // MARK -- Unsure of this property here being proper just here so the code can compile.
   @NSManaged var image: NSObject
   @NSManaged var pin: Set<Pin>
}
