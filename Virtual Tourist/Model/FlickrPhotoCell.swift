//
//  FlickrPhotoCell.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 12/31/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    @IBOutlet weak var flickrPhotoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
