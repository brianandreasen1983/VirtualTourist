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
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current Location"
    var gestureRecognizer: UILongPressGestureRecognizer!
    var selectedAnnotation: MKPointAnnotation?
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    @IBOutlet private var mapView: MKMapView!

    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
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
    
    fileprivate func setLongPressGestureRecognizer() {
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPinOnTouchAndHoldGesture))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    
    // MARK: TODO: Get the users actual location based on their device...
    fileprivate func setMapView() {
        let initLocation = CLLocation(latitude: 45, longitude: -90)
        mapView.centerToLocation(initLocation)
        mapView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Virtual Tourist"
        setTitle()
        setLongPressGestureRecognizer()
        setMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
        setupFetchedResultsController()
        placeSavedPins()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        fetchedResultsController = nil
    }
        
    fileprivate func savePin(_ annotation: MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        pin.createdDate = Date() as NSDate
        
        do{
            try dataController.viewContext.save()
            self.mapView.addAnnotation(annotation)
        } catch {
            fatalError("Core Data save error")
        }
    }
    
    @objc func dropPinOnTouchAndHoldGesture() {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        savePin(annotation)
    }
    
    // MARK: TODO -- If there is a valid location then we need to see if there are photos at tht pin to display.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? MKPointAnnotation
        
        if selectedAnnotation != nil {
            let pins = fetchedResultsController.fetchedObjects!

            for pin in pins {
                print("The latitude of the pin is: \(pin.latitude) and longitude is: \(pin.longitude) and has \(pin.photos.count) photos")
                if (pin.latitude == selectedAnnotation?.coordinate.latitude && pin.longitude == selectedAnnotation?.coordinate.longitude) {
                    if pin.photos.count > 0 {
                        print(pin.photos.count)
                        // MARK: TODO -- perform the segue and populate the data from core data in the PhotoAlbumViewController
                    
                    }
                }
            }

            performSegue(withIdentifier: "navigateToPhotoAlbumCollection", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoAlbumViewController = segue.destination as? PhotoAlbumViewController {
            photoAlbumViewController.latitude = selectedAnnotation?.coordinate.latitude ?? 0.0
            photoAlbumViewController.longitude = selectedAnnotation?.coordinate.longitude ?? 0.0
            photoAlbumViewController.dataController = dataController
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(mRegion, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setTitle() {
        title = "Virtual Tourist"
    }
    
    func placeSavedPins() {
        let pins = fetchedResultsController.fetchedObjects!
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
