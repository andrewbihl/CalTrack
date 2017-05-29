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

class MapViewController: UIViewController, GMSMapViewDelegate {

    // location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocationCoordinate2D.defaultCoordinates
    var detailVC : MapDetailViewController?
    
    var selectedStop: Stop?
    
    var tapActive = false
    
    var northTrain: GMSMarker?
    var southTrain: GMSMarker?
    
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
        mapView.delegate = self
        
        self.addTrainStopsAndPath()

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // delegate value sharing
        
        let parent = self.parent!
        detailVC = parent.childViewControllers[0] as? MapDetailViewController
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
            if stop.rawValue != Stop.tamien.rawValue || stop.rawValue != Stop.sanJose.rawValue {
            path.add(stop.stopCoordinates)
            } else {
                print("is tamien or sanjose")
            }
            marker.title = stop.stopName
            marker.map = mapView
        }
        
        let polyline = GMSPolyline(path: path)
        //polyline.strokeColor = .green
        polyline.strokeWidth = 3
        polyline.map = mapView
    }
    
    
    func addAnimatedTrain() {
        if let stop = self.selectedStop {
            let current = Calendar.dateInMinutes
            
        let (northStops, northTimes) = DataServer.sharedInstance.getNearestTrainLocation(with: stop, north: true)
            
            if northStops.count > 1 && northTimes.count > 1 {
            northTrain?.map = nil
            let northTrainLess = northStops[0].stopCoordinates
            let northTrainMore = northStops[0].stopCoordinates
                let (latDiff, longDiff)  = (northTrainMore.latitude - northTrainLess.latitude, northTrainMore.longitude - northTrainLess.longitude)
                let timeProp: Double = Double((current - northTimes[0]) / (northTimes[1] - northTimes[0]))
                let pos = CLLocationCoordinate2DMake(northTrainLess.latitude + timeProp * latDiff, northTrainLess.longitude + timeProp * longDiff)
            northTrain = GMSMarker(position: pos)
            northTrain?.icon = #imageLiteral(resourceName: "SpeedTrainSmall")
            northTrain?.map = mapView
            
                self.trainAnimation(stops: northStops, times: northTimes, current: current, first: true, north: true)
            
            }
           // print("added train from \(northFrom.stopName) to \(northTo.stopName)")
            
            if let stopPart = stop.stopPartner {
            let (southStops, southTimes) = DataServer.sharedInstance.getNearestTrainLocation(with: stopPart, north: false)
            
            if southStops.count > 1 && southTimes.count > 1 {
                southTrain?.map = nil
                let southTrainLess = southStops[0].stopCoordinates
                let southTrainMore = southStops[0].stopCoordinates
                let (latDiff, longDiff)  = (southTrainMore.latitude - southTrainLess.latitude, southTrainMore.longitude - southTrainLess.longitude)
                let timeProp: Double = Double((current - southTimes[0]) / (southTimes[1] - southTimes[0]))
                let pos = CLLocationCoordinate2DMake(southTrainLess.latitude + timeProp * latDiff, southTrainLess.longitude + timeProp * longDiff)
                southTrain = GMSMarker(position: pos)
                southTrain?.icon = #imageLiteral(resourceName: "SpeedTrainSmall")
                southTrain?.map = mapView
                
                self.trainAnimation(stops: southStops, times: southTimes, current: current, first: true, north: false)
                
            }
            }
            
    }
        
    }
        
    func trainAnimation(stops: [Stop], times: [Int], current: Int?, first: Bool, north: Bool) {
        var stops = stops
        var times = times
        if stops.count > 1 {
            
            CATransaction.begin()
            
            let lastStopTime = times.removeFirst()
                stops.removeFirst()
            
            CATransaction.setCompletionBlock ({
                self.trainAnimation(stops: stops, times: times, current: nil, first: false, north: north)
            })
            
           if first {
                print("animate for duration", CFTimeInterval((times[0] - current!) * 60))
            CATransaction.setAnimationDuration(CFTimeInterval((times[0] - current!) * 60))
            
                
            } else {
                print("animate for duration", CFTimeInterval((times[0] - lastStopTime) * 60))
                CATransaction.setAnimationDuration(CFTimeInterval((times[0] - lastStopTime) * 60))
                
            }
            if north {
            northTrain?.position = stops[0].stopCoordinates
                print("north to destination", stops[0].stopCoordinates )
            }
            else {
                southTrain?.position = stops[0].stopCoordinates
                print("south to destination", stops[0].stopCoordinates )
            }
            
            CATransaction.commit()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
    // MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude,
                                              longitude: marker.position.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        }  else {
            
            mapView.animate(to: camera)
        }
        
        self.tapActive = true
        print("You tapped at \(marker.position.latitude), \(marker.position.longitude)")
        
        if let stop = marker.position.stopWithExactPosition {
        detailVC?.stopTappedChanged(with: stop)
        }
        
        self.addAnimatedTrain()
        
        return true
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if let coord = mapView.myLocation?.coordinate {
        let camera = GMSCameraPosition.camera(withLatitude: coord.latitude,
                                              longitude: coord.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        }  else {
            
            mapView.animate(to: camera)
        }
        }
        
        detailVC?.closestStopChanged()
        
        return true
    }
    
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
             detailVC?.closestStopChanged()
        }  else {
            if !tapActive {
            mapView.animate(to: camera)
                
                 detailVC?.closestStopChanged()
            }
        }
        
        detailVC?.closestStopChanged()

    }
    
    func zoomToIncludeStop() {
        if let nearestStop = self.currentLocation?.getClosestStop {
            if let myCoordinates = self.currentLocation?.coordinate{
                let bounds = GMSCoordinateBounds(coordinate: myCoordinates, coordinate: nearestStop.stopCoordinates)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50)
                mapView.animate(with: cameraUpdate)
            }
        }
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
    func valueChangedFromLoc() -> Stop? {
        if let stop = self.currentLocation?.getClosestStop {
            if stop != self.selectedStop {
            self.selectedStop = stop
                 self.addAnimatedTrain()
                if !tapActive {
                zoomToIncludeStop()
                }
            return stop
               
            }
            else {
                return nil 
            }
        } else {
            return Stop(rawValue: 1)!
        }

    }
    
    func valueChangedFromTap(with stop: Stop) -> Stop? {
        if stop != self.selectedStop {
            self.selectedStop = stop
            return stop
        }
        else {
            return nil
        }
    }
}

