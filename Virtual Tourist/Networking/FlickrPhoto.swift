//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/2/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import Foundation

struct FlickrPhoto: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_m: String
}


