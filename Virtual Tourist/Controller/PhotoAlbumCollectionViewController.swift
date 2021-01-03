//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 12/23/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "FlickrPhoto"

class PhotoAlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var flickrPhotos: [FlickrPhoto] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        FlickrClient.getPhotosByLocation(latitude: latitude,
                                         longitude: longitude) { photosbyLocation in
            self.flickrPhotos = photosbyLocation.photos.photo
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let flickrPhoto = flickrPhotos[indexPath.row]

        guard let flickrPhotoCell  = cell as? FlickrPhotoCell else {
            return cell
        }
        
        if let url = URL(string: flickrPhoto.url_m) {
            flickrPhotoCell.configureImage(with: url)
        }

        return cell
    }
}


