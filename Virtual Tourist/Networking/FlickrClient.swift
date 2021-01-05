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
    static let apiKey = ""
    static var requestParameters: [String : String] = [:]
    
    class func getPhotosByLocation(latitude: Double, longitude: Double, page: Int?, completion: @escaping ((FlickrPhotosByLocation) -> Void)) {
        requestParameters["method"] = "flickr.photos.search"
        requestParameters["api_key"] = "\(apiKey)"
        requestParameters["lat"] = "\(latitude)"
        requestParameters["lon"] = "\(longitude)"
        requestParameters["format"] = "json"
        requestParameters["nojsoncallback"] = "1"
        requestParameters["extras"] = "url_m"
        requestParameters["media"] = "photo"
        requestParameters["per_page"] = "50"
        // If no value is provided then default it to the first page.
        requestParameters["page"] = String(page ?? 1)
        
        AF.request("\(baseURL)rest/", parameters: requestParameters )
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: FlickrPhotosByLocation.self) { (response) in
                guard let flickrPhotosByLocation = response.value else { return }
                print(flickrPhotosByLocation)
                // Insert the data into core data here?
                
                completion(flickrPhotosByLocation)
            }
    }
}
