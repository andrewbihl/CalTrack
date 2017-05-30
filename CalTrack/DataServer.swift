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
        //print("today", today, Calendar.dateInMinutes)
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
        
        
        print(self.stopTimes?.count ?? "")
        
    }
    
    public func getNearestTrainLocation(with stop: Stop, north: Bool) -> ([Stop], [Int]){ // nearest north/southbound train in format ([stops along the way], array of departure times)
        // e.g.
        let current = Calendar.dateInMinutes
        
        //let realm = try! Realm()
        if let stopTimes = stopTimes {
        let nextDep = Array(stopTimes.filter("stop_id == %@ AND departureTime > %@", stop.stopId, current).sorted(byKeyPath: "departureTime")).first // next departure from stop you've tapped
            if let nextDepTime = nextDep?.departureTime { // next departure from stop leave at
            if let realId = nextDep?.realTime?.realtime_trip_id  {// next departure from stop has realtime id
            
            var stopsRemaining = Array(stopTimes.filter("realTime.realtime_trip_id == %@ AND departureTime > %@ AND departureTime <= %@", realId, current, nextDepTime).sorted(byKeyPath: "departureTime")) // all stops from current time for this train until departure time
                
                if let stopJustPrevious = Array(stopTimes.filter("realTime.realtime_trip_id == %@ AND departureTime < %@", realId, current, nextDepTime).sorted(byKeyPath: "departureTime")).last { // stop that occured right before current time
                stopsRemaining.insert(stopJustPrevious, at: 0)
                }
                
                
                let returnStops = stopsRemaining.map({ $0.stop_id.stopWithID! })
                let stopRemainingTimes = stopsRemaining.map({ $0.departureTime })
                
                print("stops remaining (current time is \(current) and departure time is \(nextDepTime)", returnStops, stopRemainingTimes, stopsRemaining.first?.departureTime)
                
                return(returnStops, stopRemainingTimes)
            }
        }
        }
        if north {
            return ([Stop(rawValue: 2)!, Stop(rawValue: 0)!], [5])
        } else {
            return ([Stop(rawValue: 2)!, Stop(rawValue: 4)!],[4])
        }
    }
    
    public func getDepartureTimesForStop(stop: Stop) -> [Int]{ // get array of next 8 stop times
        let intDate = Calendar.dateInMinutes
        if let stopTimes = stopTimes {
            let theseStops = Array(stopTimes.filter("stop_id == %@ AND departureTime > %@", stop.stopId, intDate).sorted(byKeyPath: "departureTime")).prefix(8)
            let theseTimes = theseStops.map({ (stopTime) -> Int in
                
                return stopTime.departureTime//.getDateFromInt()
            }) 
            
            
            return theseTimes
        } else {
            return []
        }
        
    }
    
    
    
}

extension Int {
    func getDateFromInt() -> Date {
        
        let hour = (self / 60) % 24 // sometimes time is given as 24:43 for some reason
        let minute = self % 60
        var str = ""
        if hour < 10 {
            str = "0\(hour):\(minute)"
        } else {
        str = "\(hour):\(minute)"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let someDateTime = formatter.date(from: str)
        
        return someDateTime!
    }
    
    var timeRemainingText: String {
        
        let hour = (self / 60)
        let minute = self % 60
        
        var minuteDifference = hour - Calendar.current.component(.minute, from: Date())
        var hourDifference = minute - Calendar.current.component(.hour, from: Date())
        
        if minuteDifference < 0 {
            minuteDifference += 60
            hourDifference -= 1
        }
        if hourDifference == 0 {
            return "Leaves in \(String(minuteDifference)) minutes"
        }
        else {
            return "Leaves in \(String(hourDifference)) h \(String(minuteDifference)) m"
        }
    }
    
    var timeOfDepartureText: String {
        print("getting time of departure", self)
        
        var hour = self / 60
        var am = "AM"
        
        if hour > 11 {
            hour = hour % 12
            if !(hour > 23) {
            am = "PM"
            }
        }
        
        if hour == 0 {
            hour = 12
        }
        let minute = self % 60 
        var minuteString = String(minute)
        if minuteString.characters.count == 1 {
            minuteString = "0"+minuteString
        }
        return "\(hour):\(minuteString) \(am)"
        
    }
}
