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

    let UNSELECTED_MARKER_OPACITY : Float = 0.55
    // location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var mapMarkers : [Stop : GMSMarker] = [Stop : GMSMarker]()
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocationCoordinate2D.defaultCoordinates
    var detailVC : MapDetailViewController?
    
    // Once the user has interacted with the map, don't refocus to his location + nearest stop again while the view is up.
    var userHasInteracted = false
    
    var selectedStop: Stop? {
        willSet {
            if selectedStop != nil{
                if let oldMarker = mapMarkers[selectedStop!] {
                    oldMarker.opacity = UNSELECTED_MARKER_OPACITY
                } else if let partner = selectedStop?.stopPartner {
                    if let oldMarker = mapMarkers[partner] {
                        oldMarker.opacity = UNSELECTED_MARKER_OPACITY
                    }
                }
            }
            if newValue != nil {
                if let selectedMarker = mapMarkers[newValue!] {
                    selectedMarker.opacity = 1.0
                } else if let partner = newValue?.stopPartner {
                    if let selectedMarker = mapMarkers[partner] {
                        selectedMarker.opacity = 1.0
                    }
                }
            }
        }
    }
    
    var closestStop: Stop? // Need to retain this information because if you are moving and have tapped a stop you'll see it flip back to your closest stop because default behavior is to compare location to selectedStop
    // in other words, we only want a refresh of selectedStop from the location manager when your nearest stop genuinely changes (as opposed to a comparison with selectedStop)
    
    var tapActive = false
    
    var northTrain: GMSMarker?
    var southTrain: GMSMarker?
    
    var transactionID: UUID? // ensure CATransactions are abandoned appropriately
    
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
        print("initial camera zoom")
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
        self.userHasInteracted = false
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
            if stop.rawValue != Stop.tamien.rawValue && stop.rawValue != Stop.sanJose.rawValue {
                
            path.add(stop.stopCoordinates)
            } else {
                print("is tamien or sanjose")
            }
            marker.icon = #imageLiteral(resourceName: "TrainStop")
            marker.title = stop.stopName.replacingOccurrences(of: " Northbound", with: "")
            marker.map = mapView
            marker.opacity = 0.55
            mapMarkers[stop] = marker
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
            
            print("added animated train")
            
            self.transactionID = UUID()
            let unique = self.transactionID
            
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
            //northTrain?.iconView?.isUserInteractionEnabled = false
            
                self.trainAnimation(stops: northStops, times: northTimes, current: current, first: true, north: true, transactionID: unique!)
            
            }
            
            
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
                //southTrain.iconView?.isUserInteractionEnabled = false
                
                self.trainAnimation(stops: southStops, times: southTimes, current: current, first: true, north: false, transactionID: unique!)
                
            }
            }
            
    }
        
    }
        
    func trainAnimation(stops: [Stop], times: [Int], current: Int?, first: Bool, north: Bool, transactionID: UUID) {
        var stops = stops
        var times = times
        if stops.count > 1 && transactionID == self.transactionID {
            
            CATransaction.begin()
            
            let lastStopTime = times.removeFirst()
                let lastStop = stops.removeFirst()
            
            CATransaction.setCompletionBlock ({
                self.trainAnimation(stops: stops, times: times, current: nil, first: false, north: north, transactionID: transactionID)
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
                print("north to destination", stops[0].stopCoordinates, "from stop \(lastStop) to \(stops[0])")
            }
            else {
                southTrain?.position = stops[0].stopCoordinates
                print("south to destination", stops[0].stopCoordinates, "from stop \(lastStop) to \(stops[0])")
            }
            
            CATransaction.commit()
            
        } else if stops.count == 1 && !first && transactionID == self.transactionID {
            print("final destination reached")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                //if north { self.northTrain?.map = nil } else { self.southTrain?.map = nil }
                self.addAnimatedTrain()
            })
            
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
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            userHasInteracted = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        /*
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude,
                                              longitude: marker.position.longitude,
                                              zoom: zoomLevel)
        print("zooming to tapped marker \(marker.position)")
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        }  else {
            
            mapView.animate(to: camera)
        }
        
        self.tapActive = true
        print("You tapped at \(marker.position.latitude), \(marker.position.longitude)") */
        
        print("looking for stop with location \(marker.position.latitude), \(marker.position.longitude)")
        if let stop = marker.position.stopWithExactPosition {
        print("was stop", stop.stopName)
        detailVC?.stopTappedChanged(with: stop)
        }
        
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        detailVC?.closestStopChanged()
        
        return false
    }
    
    }

extension MapViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations", locations)
        
        let location = locations.last!
        print("Location: \(location)")
        self.currentLocation = location
        
        /*
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel) */
        
        if mapView.isHidden {
            mapView.isHidden = false
            //mapView.camera = camera
        
        }
        
        detailVC?.closestStopChanged() // this will take care of zoom if necessary
        self.selectedStop = self.currentLocation?.getClosestStop
    }
    
    func zoomToIncludeStop(_ stop: Stop?) {
        if let myCoordinates = self.currentLocation?.coordinate{
            if let stop = stop{
                print("zooming to include me \(myCoordinates) and nearest stop \(stop.stopCoordinates)")
                let bounds = GMSCoordinateBounds(coordinate: myCoordinates, coordinate: stop.stopCoordinates)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 60)
                mapView.animate(with: cameraUpdate)
            }
            else {
                print("couldn't retrieve nearest stop")
                let camera = GMSCameraPosition.camera(withLatitude: myCoordinates.latitude ,
                                                      longitude: myCoordinates.longitude,
                                                      zoom: zoomLevel)
                mapView.camera = camera
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
            if stop != self.closestStop && stop != self.selectedStop {
            self.selectedStop = stop
            self.closestStop = stop 
                 self.addAnimatedTrain()
                if !tapActive && !userHasInteracted {
                    print("zooming because location changed")
                    zoomToIncludeStop(stop)
                    mapMarkers[stop]?.opacity = 1.0
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
            self.addAnimatedTrain()
            return stop
        }
        else {
            return nil
        }
    }
}

