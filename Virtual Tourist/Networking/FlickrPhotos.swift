//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/2/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import Foundation

struct FlickrPhotos: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}

enum CodingKeys: String, CodingKey {
 case page
 case pages
 case perpage
 case total
 case photo
}
