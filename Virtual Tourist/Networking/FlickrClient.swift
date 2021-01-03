//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 12/23/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Improve this to have only 100 items returned instead of 250.
class FlickrClient {
    static let baseURL = "https://www.flickr.com/services/"
    static let apiKey = "cb5db23d1e62d82b56c52c409e071100"

    class func getPhotosByLocation(latitude: Double, longitude: Double, completion: @escaping ((FlickrPhotosByLocation) -> Void)) {
        AF.request("\(baseURL)rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&extras=url_m&media=photo&per_page=50")
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])          
            .responseDecodable(of: FlickrPhotosByLocation.self) { (response) in
                guard let flickrPhotosByLocation = response.value else { return }
                print(flickrPhotosByLocation)
                completion(flickrPhotosByLocation)
            }
    }
}
