//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Brian Andreasen on 6/23/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet private var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current Location"
    var gestureRecognizer: UILongPressGestureRecognizer!
    var selectedAnnotation: MKPointAnnotation?
    var context: NSManagedObjectContext?
    
//    private lazy var fetchedResultsController: NSFetchedResultsController<Pin> = {
//        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//        fetchRequest.fetchLimit = 100
//
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
//        frc.delegate = self
//
//        return frc
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Virtual Tourist"
        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("Core Data fetch error")
//        }
        
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPinOnTouchAndHoldGesture))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let initLocation = CLLocation(latitude: 45, longitude: 95)
        mapView.centerToLocation(initLocation)
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
        
    @objc func dropPinOnTouchAndHoldGesture() {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
//        guard let context = self.context else { return }
        
//        let newLocation = Pin(context: context)
//        newLocation.latitude = annotation.coordinate.latitude
//        newLocation.longitude = annotation.coordinate.longitude
        
        self.mapView.addAnnotation(annotation)

        // Save pin here
//        do {
//            try context.save()
//        } catch {
//            fatalError("Core Data save error")
//        }
    }
    
    // MARK -- When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        
        if self.selectedAnnotation != nil {
            // MARK: Improvement -- to improve this make the API call here and then present after the data has been loaded.
            let photoAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumCollectionViewController") as! PhotoAlbumCollectionViewController
            self.present(photoAlbumVC, animated: true, completion: nil)
            
            photoAlbumVC.latitude = self.selectedAnnotation?.coordinate.latitude ?? 0.0
            photoAlbumVC.longitude = self.selectedAnnotation?.coordinate.longitude ?? 0.0
        }
    }

    // MARK -- CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(mRegion, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    // MARK -- Instance Methods
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
