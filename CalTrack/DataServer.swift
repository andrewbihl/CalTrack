//
//  DataServer.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation
import CoreLocation

class DataServer {
    
    public func getDepartureTimesForStop(id: Int) -> [Date]{
        return [Date.distantFuture]
    }
    
    
    /// Get all the stops with a particular direction.
    ///
    /// - Parameter headingNorth: If true, get stops with trains heading north toward San Francisco. Otherwise, get stops heading south to San Jose.
    public func getStopLocations(headingNorth: Bool) -> [CLLocationCoordinate2D] {
        return [CLLocationCoordinate2DMake(0, 0)]
    }
    
}
