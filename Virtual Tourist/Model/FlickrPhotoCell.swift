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
    
    func configureImage(with url: URL) {
        do {
            self.flickrPhotoImageView.image = nil
            startActivityIndicator()
            let imageData = try Data(contentsOf: url)
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.flickrPhotoImageView.image = image
                self.stopActivityIndicator()
            }
        } catch {
            stopActivityIndicator()
        }
    }
    
    private func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
