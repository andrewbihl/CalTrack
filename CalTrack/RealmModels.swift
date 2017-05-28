//
//  RealmObjects.swift
//  CalTrack
//
//  Created by Faris Sbahi on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation
import RealmSwift

class stop_times: Object {
    dynamic var trip_id = ""
    dynamic var arrival_time = "" // Military time string
    dynamic var departure_time = "" // ""
    dynamic var stop_id = 0
    dynamic var stop_sequence = 0
    dynamic var pickup_type = 0
    dynamic var drop_off_type = 0
    
    dynamic var arrivalTime = 0 // arrival_time converted, minutes from 00:00
    dynamic var departureTime = 0 // ""
    
    dynamic var realTime: realtime_trips?
}

class realtime_trips: Object {
    dynamic var trip_id = ""
    dynamic var realtime_trip_id = ""
    
    override class func primaryKey() -> String? {
        return "trip_id"
    }
}
