//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 1/3/21.
//  Copyright © 2021 Brian Andreasen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "FlickrPhotoCell"

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate,
                                UICollectionViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate,
                                UIGestureRecognizerDelegate  {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Core Data failure: \(error.localizedDescription)")
        }
    }
    
    @IBAction func createCollection(_ sender: Any) {
        if ((fetchedResultsController.fetchedObjects?.isEmpty) != nil) {
            // MARK: TODO -- Remove all of the records from core data
        }
        
        let randomPage = Int.random(in: 1...50)
        FlickrClient.getPhotosByLocation(latitude: 45, longitude: -90, page: randomPage) { photosByLocation in
            if randomPage > photosByLocation.photos.pages {
                self.showNoImagesLabel()
                self.collectionView.reloadData()
                return
            } else {
                self.hideNoImagesLabel()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setupFetchedResultsController()
        disableNewCollectionButton()
        collectionView.dataSource = self
        collectionView.delegate = self
        hideNoImagesLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        FlickrClient.getPhotosByLocation(latitude: 45,
                                         longitude: -90, page: 1) { photosbyLocation in
        
            if photosbyLocation.photos.photo.count == 0 {
                self.showNoImagesLabel()
            } else {
                // MARK -- This seems  wildly inefficient to be using it like this.
                for photo in photosbyLocation.photos.photo {
                    let photoInstance = Photo(context: self.dataController.viewContext)

                    do{
                        let photoUrl = URL(string: photo.url_m)
                        let imageData = try Data(contentsOf: photoUrl!)

                        photoInstance.image = imageData as NSData
                    } catch {
                        fatalError("Core Data save error")
                    }
                }
                
                if self.dataController.viewContext.hasChanges {
                    do{
                        try self.dataController.viewContext.save()
                        self.hideNoImagesLabel()
                        self.enableNewCollectionButton()
                        self.collectionView.reloadData()
                    } catch {
                        print("Core Data error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func enableNewCollectionButton() {
        newCollectionButton.isEnabled = true
    }
    
    func disableNewCollectionButton() {
        newCollectionButton.isEnabled = false
    }
    
    func showNoImagesLabel() {
        noImagesLabel.isHidden = false
    }
    
    func hideNoImagesLabel() {
        noImagesLabel.isHidden = true
    }
    
    func setTitle() {
        title = "Photo Collection"
    }
    
    // MARK: UICollectionView Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let flickrPhoto = fetchedResultsController.object(at: indexPath)

        guard let flickrPhotoCell  = cell as? FlickrPhotoCell else {
            return cell
        }

        // If the data image data is data then assign it to the cell and create a new cell otherwise use a placeholder.
        
        DispatchQueue.main.async {
            flickrPhotoCell.startActivityIndicator()

            if let data = flickrPhoto.image as Data? {
                flickrPhotoCell.flickrPhotoImageView.image = UIImage(data: data)
            } else {
                flickrPhotoCell.flickrPhotoImageView.image = UIImage(named: "placeholder-image")
            }
            
            flickrPhotoCell.stopActivityIndicator()
        }

        return cell
    }
    // MARK: TODO -- Implementing selecting and deselecting in UICollectionView
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView.deleteItems(at: [indexPath!])
                break
            case .update:
                break
            case .move:
                break
        }
    }
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        <#code#>
//    }
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        <#code#>
//    }
}
