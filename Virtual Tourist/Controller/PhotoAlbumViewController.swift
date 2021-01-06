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
    
    // MARK: TODO -- Remove all of the records from Core Data
    // Perform an API Call and store the new photos back in Core Data
    @IBAction func createCollection(_ sender: Any) {
        if fetchedResultsController.fetchedObjects!.count > 0 {
            deleteAllPhotosFromCoreData()
        }
        
        let randomPage = Int.random(in: 1...50)
        FlickrClient.getPhotosByLocation(latitude: 45, longitude: -90, page: randomPage) { photosByLocation in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setTitle()
        setupFetchedResultsController()
//        disableNewCollectionButton()
        hideNoImagesLabel()
    }
    
    fileprivate func getPhotosByLocation() {
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
        // If there are no photos fetched from Core Data then go an API call to get the photos by location
        if photos.count <= 0 {
            getPhotosByLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        fetchedResultsController = nil
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
    
    
    
    // MARK: TODO -- I believe the deleteion needs to be handled on the background context since this could be a lengthy process.
    // Issues: UI is not reactive to this.
    func deleteAllPhotosFromCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Photo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try dataController.viewContext.execute(deleteRequest)
            try dataController.viewContext.save()
        } catch let error as NSError {
            // TODO: handle the error
            print(error.localizedDescription)
        }
    }

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
                collectionView.reloadItems(at: [indexPath!])
                break
            case .move:
                break
        }
    }
}
