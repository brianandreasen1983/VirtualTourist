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
    
    // Member Variables
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // IB Actions
    @IBAction func createCollection(_ sender: Any) {
        if fetchedResultsController.fetchedObjects!.count > 0 {
            deleteAllPhotosFromCoreData()
        }
        
        getRandomPhotosFromFlickr()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
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
    
    // MARK: TODO --
    fileprivate func getRandomPhotosFromFlickr() {
        let randomPage = Int.random(in: 1...50)
        FlickrClient.getPhotosByLocation(latitude: latitude, longitude: longitude, page: randomPage) { photosByLocation in
            if randomPage > photosByLocation.photos.pages {
                self.showNoImagesLabel()
                return
            } else {
                self.hideNoImagesLabel()
                for photo in photosByLocation.photos.photo {
                    let photoInstance = Photo(context: self.dataController.viewContext)
                    
                    do{
                        let photoUrl = URL(string: photo.url_m)
                        let imageData = try Data(contentsOf: photoUrl!)
                        
                        photoInstance.createdDate = Date() as NSDate
                        photoInstance.image = imageData as NSData
                    } catch {
                        fatalError("Core Data save error")
                    }
                }
                
                if self.dataController.viewContext.hasChanges {
                    do{
                        try? self.dataController.viewContext.save()
                        self.hideNoImagesLabel()
                        self.enableNewCollectionButton()
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                        }
                    } catch {
                        print("Core Data error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setTitle()
        setupFetchedResultsController()
        disableNewCollectionButton()
        hideNoImagesLabel()
    }
    
    fileprivate func getPhotosByLocation() {
        FlickrClient.getPhotosByLocation(latitude: latitude,
                                         longitude: longitude, page: 1) { photosbyLocation in
            
            if photosbyLocation.photos.photo.count == 0 {
                self.showNoImagesLabel()
            } else {
                // MARK -- This seems  wildly inefficient to be using it like this.
                for photo in photosbyLocation.photos.photo {
                    let photoInstance = Photo(context: self.dataController.viewContext)
                    
                    do{
                        let photoUrl = URL(string: photo.url_m)
                        let imageData = try Data(contentsOf: photoUrl!)
                        
                        photoInstance.createdDate = Date() as NSDate
                        photoInstance.image = imageData as NSData
                    } catch {
                        fatalError("Core Data save error")
                    }
                }
                
                if self.dataController.viewContext.hasChanges {
                    do{
                        try? self.dataController.viewContext.save()
                        self.hideNoImagesLabel()
                        self.enableNewCollectionButton()
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                        }
                    } catch {
                        print("Core Data error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
        let photos = fetchedResultsController.fetchedObjects!
        if photos.count <= 0 {
            getPhotosByLocation()
        }
        
        enableNewCollectionButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        fetchedResultsController = nil
    }
    
    // Methods
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
    
    func deleteAllPhotosFromCoreData() {
        for photo in fetchedResultsController.fetchedObjects ?? [] {
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
    }

}

// PhotoAlbumViewController extensions
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let flickrPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        

        guard let flickrPhotoCell  = cell as? FlickrPhotoCell else {
            return cell
        }
        
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView.deleteItems(at: [indexPath!])
                break
            case .update:
                collectionView.reloadItems(at: [indexPath!])
                break
            case .move:
                break
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let flickrPhotoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(flickrPhotoToDelete)
        try? dataController.viewContext.save()
        try? collectionView.reloadData()
    }
}
