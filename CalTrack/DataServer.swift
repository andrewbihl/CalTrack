//
//  DataServer.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class DataServer {
    
    public static let sharedInstance = DataServer()

    var stopTimes: Results<stop_times>?
    
    init() {
        let date = Date()
        let today = Calendar.current.component(.weekday, from: date)
        print("today", today, Calendar.dateInMinutes)
        let realm = try! Realm()
        
        switch today {
        case 1:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Sunday")
        case 2...6:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Weekday")
        case 7:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Saturday")
        default:
            print("ERROR: Unknown day of the week -- potential apocalypse nearing")
            
        }
        
        
        print(self.stopTimes?.count)
        
    }
    
    public func getNearestTrainLocation() {
        
    }
    
    public func getDepartureTimesForStop(stop: Stop) -> [Date]{ // get array of next 8 stop times
        return [Date.distantFuture]
    }
    
    
    
}

extension Int {
    func getDateFromInt() {
        let str = "\(self / 60):\(self % 60)"
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let someDateTime = formatter.date(from: str)
        return someDateTime
    }
}
