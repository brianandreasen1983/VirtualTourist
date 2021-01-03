//
//  FlickrPhotosByLocation.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/2/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import Foundation

struct FlickrPhotosByLocation: Decodable {
    let photos: FlickrPhotos
    let stat: String
}
