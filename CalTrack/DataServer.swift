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
        let intDate = Calendar.dateInMinutes
        if let stopTimes = stopTimes {
            let theseStops = Array(stopTimes.filter("stop_id == %@ AND departureTime > %@", stop.stopId, intDate).sorted(byKeyPath: "departureTime")).prefix(8)
            let theseTimes = theseStops.map({ (stopTime) -> Date in
                return stopTime.departureTime.getDateFromInt()
            }) 
            
            print(theseStops, theseTimes)
            return theseTimes
        } else {
            return []
        }
        
    }
    
    
    
}

extension Int {
    func getDateFromInt() -> Date {
        
        let hour = self / 60
        let minute = self % 60
        var str = ""
        if hour < 10 {
            str = "0\(self / 60):\(self % 60)"
        } else {
        str = "\(self / 60):\(self % 60)"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let someDateTime = formatter.date(from: str)
        return someDateTime!
    }
}
