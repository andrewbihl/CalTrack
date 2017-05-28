//
//  MapViewController.swift
//  CalTrack
//
//  Created by Faris Sbahi on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    // location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocationCoordinate2D.defaultCoordinates
    var detailVC : MapDetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 50 // meters
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            print("start updating location")
        }
        
        // create map
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.latitude,
                                              longitude: defaultLocation.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view = mapView
        mapView.isHidden = true
        
        self.addTrainStopsAndPath()
        self.showTimesForClosestStop()
        self.addAnimatedTrain()
        
        // delegate value sharing
        
        detailVC = MapDetailViewController()
        detailVC?.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addTrainStopsAndPath() {
        let path = GMSMutablePath()
        let stops = Stop.getStops(headingNorth: true)
        
        for stop in stops {
            let marker = GMSMarker(position: stop.stopCoordinates)
            path.add(stop.stopCoordinates)
            marker.map = mapView
        }
        
        let polyline = GMSPolyline(path: path)
        //polyline.strokeColor = .green
        polyline.strokeWidth = 3
        polyline.map = mapView
    }
    
    func showTimesForClosestStop() {
        
    }
    
    func addAnimatedTrain() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
    }

extension MapViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations", locations)
        
            let location = locations.last!
            print("Location: \(location)")
            self.currentLocation = location
        
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        }  else {
            mapView.animate(to: camera)
        }
        
        detailVC?.closestStopChanged()

    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController: InformingDelegate {
    func valueChanged() -> Stop {
        if let stop = self.currentLocation?.getClosestStop {
            return stop
        } else {
            return Stop(rawValue: 1)!
        }

    }
}

