//
//  Constants.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public let defaultLatitude = 37.788153
public let defaultLongitude = -122.406468
public let defaultNorthStop = Stop.sanFranciscoNorthbound
public let defaultSouthStop = Stop.sanFranciscoSouthbound


public let appColor1 = UIColor(red:0.31, green:0.75, blue:0.62, alpha:0.91)
public let appColor2 = #colorLiteral(red: 0.7428558469, green: 0.895416677, blue: 0.8669404387, alpha: 1)

public enum Stop: Int {
    case sanFranciscoNorthbound = 0, sanFranciscoSouthbound,
    twentySecondStreetNorthbound, twentySecondStreetSouthbound,
    bayshoreNorthbound, bayshoreSouthbound,
    southSanFranciscoNorthbound, southSanFranciscoSouthbound,
    sanBrunoNorthbound, sanBrunoSouthbound,
    millbraeNorthbound, millbraeSouthbound,
    broadwayNorthbound, broadwaySouthbound,
    burlingameNorthbound, burlingameSouthbound,
    sanMateoNorthbound, sanMateoSouthbound,
    haywardParkNorthbound, haywardParkSouthbound,
    hillsdaleNorthbound, hillsdaleSouthbound,
    belmontNorthbound, belmontSouthbound,
    sanCarlosNorthbound, sanCarlosSouthbound,
    redwoodCityNorthbound, redwoodCitySouthbound,
    athertonNorthbound, athertonSouthbound,
    menloParkNorthbound, menloParkSouthbound,
    paloAltoNorthbound, paloAltoSouthbound,
    californiaAveNorthbound, californiaAveSouthbound,
    sanAntonioNorthbound, sanAntonioSouthbound,
    mountainViewNorthbound, mountainViewSouthbound,
    sunnyvaleNorthbound, sunnyvaleSouthbound,
    lawrenceNorthbound, lawrenceSouthbound,
    santaClaraNorthbound, santaClaraSouthbound,
    collegeParkNorthbound, collegeParkSouthbound,
    sanJoseDiridonNorthbound, sanJoseDiridonSouthbound,
    tamienNorthbound, tamienSouthbound,
    capitolNorthbound, capitolSouthbound,
    blossomHillNorthbound, blossomHillSouthbound,
    morganHillNorthbound, morganHillSouthbound,
    sanMartinNorthbound, sanMartinSouthbound,
    gilroyNorthbound, gilroySouthbound,
    sanJose,
    tamien
    
    static let allValues = [sanFranciscoNorthbound, sanFranciscoSouthbound,
                            twentySecondStreetNorthbound, twentySecondStreetSouthbound,
                            bayshoreNorthbound, bayshoreSouthbound,
                            southSanFranciscoNorthbound, southSanFranciscoSouthbound,
                            sanBrunoNorthbound, sanBrunoSouthbound,
                            millbraeNorthbound, millbraeSouthbound,
                            broadwayNorthbound, broadwaySouthbound,
                            burlingameNorthbound, burlingameSouthbound,
                            sanMateoNorthbound, sanMateoSouthbound,
                            haywardParkNorthbound, haywardParkSouthbound,
                            hillsdaleNorthbound, hillsdaleSouthbound,
                            belmontNorthbound, belmontSouthbound,
                            sanCarlosNorthbound, sanCarlosSouthbound,
                            redwoodCityNorthbound, redwoodCitySouthbound,
                            athertonNorthbound, athertonSouthbound,
                            menloParkNorthbound, menloParkSouthbound,
                            paloAltoNorthbound, paloAltoSouthbound,
                            californiaAveNorthbound, californiaAveSouthbound,
                            sanAntonioNorthbound, sanAntonioSouthbound,
                            mountainViewNorthbound, mountainViewSouthbound,
                            sunnyvaleNorthbound, sunnyvaleSouthbound,
                            lawrenceNorthbound, lawrenceSouthbound,
                            santaClaraNorthbound, santaClaraSouthbound,
                            collegeParkNorthbound, collegeParkSouthbound,
                            sanJoseDiridonNorthbound, sanJoseDiridonSouthbound,
                            tamienNorthbound, tamienSouthbound,
                            capitolNorthbound, capitolSouthbound,
                            blossomHillNorthbound, blossomHillSouthbound,
                            morganHillNorthbound, morganHillSouthbound,
                            sanMartinNorthbound, sanMartinSouthbound,
                            gilroyNorthbound, gilroySouthbound,
                            sanJose,
                            tamien]
    
    static var count: Int { return Stop.tamien.hashValue + 1}
    
    static func getStops(headingNorth: Bool) -> [Stop] {
        let stops = Stop.allValues.filter { (stopName) -> Bool in
            return (stopName.rawValue % 2 == 0) ? headingNorth : !headingNorth
        }
        return stops
    }
    
}


public extension Stop {
    
    var stopName: String {
        let stopNames = ["San Francisco Northbound", "San Francisco Southbound", "22nd St Northbound", "22nd St Southbound", "Bayshore Northbound", "Bayshore Southbound", "South San Francisco Northbound", "South San Francisco Southbound", "San Bruno Northbound", "San Bruno Southbound", "Millbrae Northbound", "Millbrae Southbound", "Broadway Northbound", "Broadway Southbound", "Burlingame Northbound", "Burlingame Southbound", "San Mateo Northbound", "San Mateo Southbound", "Hayward Park Northbound", "Hayward Park Southbound", "Hillsdale Northbound", "Hillsdale Southbound", "Belmont Northbound", "Belmont Southbound", "San Carlos Northbound", "San Carlos Southbound", "Redwood City Northbound", "Redwood City Southbound", "Atherton Northbound", "Atherton Southbound", "Menlo Park Northbound", "Menlo Park Southbound", "Palo Alto Northbound", "Palo Alto Southbound", "California Ave Northbound", "California Ave Southbound", "San Antonio Northbound", "San Antonio Southbound", "Mountain View Northbound", "Mountain View Southbound", "Sunnyvale Northbound", "Sunnyvale Southbound", "Lawrence Northbound", "Lawrence Southbound", "Santa Clara Northbound", "Santa Clara Southbound", "College Park Northbound", "College Park Southbound", "San Jose Diridon Northbound", "San Jose Diridon Southbound", "Tamien Northbound", "Tamien Southbound", "Capitol Northbound", "Capitol Southbound", "Blossom Hill Northbound", "Blossom Hill Southbound", "Morgan Hill Northbound", "Morgan Hill Southbound", "San Martin Northbound", "San Martin Southbound", "Gilroy Northbound", "Gilroy Southbound", "San Jose Northbound", "Tamien Southbound"]
        return stopNames[self.rawValue]
    }
    
    var stopLatitude: Double {
        let stopLatitudes = [37.77639, 37.776348, 37.757599, 37.757583, 37.709537, 37.709544, 37.65589, 37.655946, 37.631128, 37.631108, 37.59988, 37.599797, 37.58764, 37.587552, 37.580197, 37.580186, 37.568087, 37.568294, 37.552938, 37.552994, 37.537868, 37.537814, 37.52089, 37.520844, 37.50805, 37.507933, 37.486159, 37.486101, 37.464645, 37.464584, 37.454856, 37.454745, 37.443475, 37.443405, 37.429365, 37.429333, 37.407323, 37.407277, 37.394459, 37.394402, 37.378916, 37.378789, 37.370598, 37.370484, 37.353238, 37.353189, 37.342384, 37.342338, 37.329239, 37.329231, 37.31174, 37.31175, 37.284102, 37.284062, 37.252422, 37.252379, 37.129363, 37.129321, 37.085225, 37.086653, 37.003538, 37.003485, 37.330196, 37.311638]
        return stopLatitudes[self.rawValue]
    }
    
    var stopLongitude: Double {
        let stopLongitudes = [-122.394992, -122.394935, -122.39188, -122.392404, -122.401586, -122.40198, -122.40487, -122.405018, -122.411968, -122.412076, -122.386647, -122.386832, -122.36265, -122.362708, -122.3449, -122.345075, -122.323851, -122.324092, -122.309338, -122.309608, -122.297349, -122.297461, -122.275738, -122.275816, -122.26015, -122.260266, -122.231936, -122.232, -122.19779, -122.197869, -122.182297, -122.182405, -122.164614, -122.164697, -122.141927, -122.141978, -122.107069, -122.107125, -122.075956, -122.075994, -122.031372, -122.031423, -121.997114, -121.997135, -121.93608, -121.936135, -121.9146, -121.914677, -121.903011, -121.903173, -121.883721, -121.883999, -121.841955, -121.842037, -121.797643, -121.797683, -121.650244, -121.650304, -121.610049, -121.610936, -121.566088, -121.566225, -121.901985, -121.883403]
        
        return stopLongitudes[self.rawValue]
    }
    
    var stopId: Int {
        let stopIDs = [70011, 70012, 70021, 70022, 70031, 70032, 70041, 70042, 70051, 70052, 70061, 70062, 70071, 70072, 70081, 70082, 70091, 70092, 70101, 70102, 70111, 70112, 70121, 70122, 70131, 70132, 70141, 70142, 70151, 70152, 70161, 70162, 70171, 70172, 70191, 70192, 70201, 70202, 70211, 70212, 70221, 70222, 70231, 70232, 70241, 70242, 70251, 70252, 70261, 70262, 70271, 70272, 70281, 70282, 70291, 70292, 70301, 70302, 70311, 70312, 70321, 70322, 777402, 777403]
        
        return stopIDs[self.rawValue]
    }
    
    var stopCoordinates: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(self.stopLatitude, self.stopLongitude)
    }
    
    /*
    static func distanceToStop(stop: Stop, fromLocation location: CLLocationCoordinate2D) {
        return
    }
     */
    
}

extension Sequence where Iterator.Element == Stop {
    
    var getStopLocations: [CLLocationCoordinate2D] {
        
        return self.map ({
            $0.stopCoordinates
        })
        }

 }

extension CLLocationCoordinate2D {
    public static let defaultCoordinates = CLLocationCoordinate2DMake(defaultLatitude, defaultLongitude)
    
    
    
}

extension CLLocation {
    
    var getClosestStop:  Stop {
        let stopLocations = Stop.allValues//.getStopLocations
        
        var resStop: Stop?
        var leastDistance: CLLocationDistance = 10000000.0
        
        for stop in stopLocations {
            let dist = self.distance(from: CLLocation(coordinate: stop.stopCoordinates, altitude: 0, horizontalAccuracy:  5, verticalAccuracy: 5, timestamp: Date()))
            if dist < leastDistance {
                leastDistance = dist
                resStop = stop
            }
        }
        
        if resStop != nil{
        return resStop!
        } else {
            return Stop(rawValue: 0)!
        }
    }
}

extension Calendar {
    
    static var dateInMinutes: Int {
        let date = Date()
        let hour = self.current.component(.hour, from: date)
        let minute = self.current.component(.minute, from: date)
        
        return 60 * hour + minute
    }
}

extension Date {
    var dateInMinutes: Int {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.minute, from: self)
        
        return 60 * hour + minute
    }
}
