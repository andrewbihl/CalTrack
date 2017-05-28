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
    dynamic var arrival_time = ""
    dynamic var departure_time = ""
    dynamic var stop_id = 0
    dynamic var stop_sequence = 0
    dynamic var pickup_type = 0
    dynamic var drop_off_type = 0
    
    dynamic var arrivalTime = 0
    dynamic var departureTime = 0
}
