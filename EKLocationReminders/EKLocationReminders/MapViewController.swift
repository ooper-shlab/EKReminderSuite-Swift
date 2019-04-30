//
//  MapViewController.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller displays a map with annotations if the app has access to Reminders and an empty map, otherwise.
         Tap any annotation's callout to create a reminder for that location.

 */
import UIKit
import MapKit
import EventKit
import CoreLocation

private let EKLRRegionDelta = 2.12
private let EKLRRegionLatitude = 37.78699
private let EKLRRegionLongitude = -122.4401


private let EKRSAnnotationAddress = "address"
private let EKRSAnnotationLatitude = "latitude"
private let EKRSAnnotationLongitude = "longitude"


private let EKLRLocationsList = "Locations"
private let EKLRLocationsListExtension = "plist"
private let kPinAnnotationViewIdentifier = "pinAnnotationViewIdentifier"


@objc(MapViewController)
class MapViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    private var selectedAnnotation: MKAnnotation?
    @IBOutlet private weak var mapView: MKMapView!
    private var locationManager: CLLocationManager?
    private var selectedStructureLocation: EKStructuredLocation?
    private var currentUserLocationAddress: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleLTBControllerNotification(_:)),
            name: NSNotification.Name(LTBAccessGrantedNotification),
            object: nil)
        
    }
    
    
    //MARK: - Location Access Methods
    
    private func checkLocationServicesAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            self.accessGrantedForLocationServices()
        case .notDetermined:
            self.requestLocationServicesAuthorization()
        case .denied, .restricted:
            if !self.mapView.annotations.isEmpty {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            
            let alert = EKRSHelperClass.alert(title: NSLocalizedString("Privacy Warning", comment: ""),
                message: NSLocalizedString("Access was not granted for Location Services.", comment: ""))
            
            self.present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    
    private func requestLocationServicesAuthorization() {
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
        }
        
        // Ask for user permission to find our location
        self.locationManager!.requestWhenInUseAuthorization()
    }
    
    
    
    //MARK: - Handle LocationTabBarController Notification
    
    @objc func handleLTBControllerNotification(_ notification: Notification) {
        self.accessGrantedForReminders()
    }
    
    
    //MARK: - Handle Location Services Access
    
    /*
    
    This sample uses data from the Locations.plist file to create annotations for the map. Locations.plist includes an array of dictionaries
    that each represents the title, latitude, longitude, and address information of an annotation. Additionally, accessGrantedForLocationServices
    adds the current user location to Map. Update this file with data formatted as described above if you wish to test reminders around other locations.
    Note that you can obtain latitude, longitude, and delta information by following these steps:
    1) Implement
    - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
    
    2) Zoom or pan to the area you want in Map, then set a breakpoint there to obtain information about the region.
    
    3) Display the latitude, longitude, and delta information by executing po mapview.region in the debugger.
    
    */
    
    private func accessGrantedForLocationServices() {
        
        if !self.mapView.annotations.isEmpty {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        // Locations.plist contains all data required for configuring the map's region and points of interest
        let plistURL = Bundle.main.url(forResource: EKLRLocationsList, withExtension: EKLRLocationsListExtension)!
        let data = NSArray(contentsOf: plistURL)!
        
        
        self.mapView.addAnnotations(self.fetchAnnotations(data))
        self.mapView.showsUserLocation = true
    }
    
    
    //MARK: - Handle Reminders Access
    
    
    private func accessGrantedForReminders() {
        self.checkLocationServicesAuthorizationStatus()
    }
    
    
    //MARK: - Fetch Interest Points
    
    private func fetchAnnotations(_ locations: NSArray) -> [MKAnnotation] {
        var annotations: [MKAnnotation] = []
        annotations.reserveCapacity(locations.count)
        
        for dict in locations as! [[String: AnyObject]] {
            let myAnnotation = MyAnnotation(title: dict[EKRSTitle] as! String?,
                latitude: dict[EKRSAnnotationLatitude] as! Double,
                longitude: dict[EKRSAnnotationLongitude] as! Double,
                address: dict[EKRSAnnotationAddress] as! String?)
            
            
            annotations.append(myAnnotation)
        }
        
        return annotations
    }
    
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error: \(error)")
    }
    
    
    // Called when the authorization status changes for Location Services
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check the authorization status and take the appropriate action
        self.checkLocationServicesAuthorizationStatus()
    }
    
    
    //MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let geocoder = CLGeocoder()
        
        // Reverse-geocode the current user coordinates
        geocoder.reverseGeocodeLocation(location) {placemarks, error in
            if let placemarks = placemarks, !placemarks.isEmpty {
                let placemark = placemarks.first!
                self.currentUserLocationAddress = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? "")"
            }
        }
        
        // Create a region using the current user location
        var region = MKCoordinateRegion()
        region.span = MKCoordinateSpan(latitudeDelta: EKLRRegionDelta, longitudeDelta: EKLRRegionDelta)
        region.center = CLLocationCoordinate2DMake(userLocation.location?.coordinate.latitude ?? 0.0, userLocation.location?.coordinate.longitude ?? 0.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = self.mapView.dequeueReusableAnnotationView(withIdentifier: kPinAnnotationViewIdentifier) as! MKPinAnnotationView?
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation,
                reuseIdentifier: kPinAnnotationViewIdentifier)
            
            if #available(iOS 9.0, *) {
                pinView!.pinTintColor = MKPinAnnotationView.purplePinColor()
            } else {
                pinView!.pinColor = MKPinAnnotationColor.purple
            }
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
        
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let story = UIStoryboard(name: "LocationReminders", bundle: nil)
        let navigationController = story.instantiateViewController(withIdentifier: "navAddLocationReminderVCID") as! UINavigationController
        
        
        let addLocationReminderViewController = navigationController.topViewController! as! AddLocationReminder
        
        if  view.annotation is MyAnnotation {
            let myAnnotation = view.annotation as! MyAnnotation
            
            addLocationReminderViewController.name = myAnnotation.title
            addLocationReminderViewController.address = myAnnotation.address
        } else {
            let userLocation = view.annotation as! MKUserLocation
            // We selected the user location
            addLocationReminderViewController.name = userLocation.title
            addLocationReminderViewController.address =  self.currentUserLocationAddress
        }
        
        self.selectedAnnotation = view.annotation
        
        self.navigationController!.present(navigationController, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    }
    
    
    //MARK: - Unwind Segues
    
    // Dismiss the Add Location Reminder view controller
    @IBAction func cancel(_: UIStoryboardSegue) {
    }
    
    
    @IBAction func done(_ sender: UIStoryboardSegue) {
        let addLocationReminderViewController = sender.source as! AddLocationReminder
        
        let dictionary = addLocationReminderViewController.userInput
        
        // If the selected annotation is the current user location, show its address rather than Current Location. Show its title, otherwise.
        let location = (self.selectedAnnotation is MKUserLocation) ?
            EKStructuredLocation(title: self.currentUserLocationAddress!) :
            EKStructuredLocation(title: self.selectedAnnotation!.title! ?? "")
        
        
        location.geoLocation = CLLocation(latitude: self.selectedAnnotation!.coordinate.latitude,
            longitude: self.selectedAnnotation!.coordinate.longitude)
        
        // Convert from miles to meters before assigning it to the radius property
        location.radius = kMeter * (dictionary[EKRSLocationRadius] as! Double)
        
        
        let newLocationReminder = LocationReminder(title: dictionary[EKRSTitle] as! String?,
            proximity: dictionary[EKRSLocationProximity] as! String,
            structureLocation: location)
        
        
        LocationReminderStore.shared.createLocationReminder(newLocationReminder)
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(LTBAccessGrantedNotification),
            object: nil)
    }
    
}
