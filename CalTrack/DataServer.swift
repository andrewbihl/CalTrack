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
import Firebase
import FirebaseDatabase
import FirebaseAuth

class DataServer {
    
    public static let sharedInstance = DataServer()
    
    let STOP_TIMES_SHOWN_COUNT = 16

    var stopTimes: Results<stop_times>?
    var ref: DatabaseReference!
    
    
    init() {
        
        ref = Database.database().reference()
        
        
        Auth.auth().signInAnonymously() { (user, error) in // sign in anonymously (allows us to retain user settings such as bookmarked stations without actually requiring sign-up)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.ref.child("users").child((user?.uid)!).setValue(["version": version]) // write the app version this user is using to the db
            }
        }
        
        let date = Date()
        let today = Calendar.current.component(.weekday, from: date)
        
        let isHoliday = date.isTodayAHoliday
        
        print("today is a holiday? \(isHoliday)")
        
        print("today", today, date)
        let realm = try! Realm()
        
        switch today {
        case let x where x == 1 || isHoliday:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Sunday")
        case 2...6:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Weekday")
        case 7:
            self.stopTimes = realm.objects(stop_times.self).filter("trip_id contains %@", "Saturday")
        default:
            print("ERROR: Unknown day of the week -- potential apocalypse nearing")
            
        }
        
        
        print(self.stopTimes?.count ?? "")
        print("data server initialization complete")
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
    
    public func getDepartureTimesForStop(stop: Stop) -> [Int]{ // get array of next n stop times
        let intDate = Calendar.dateInMinutes
        if let stopTimes = stopTimes {
            let theseStops = Array(stopTimes.filter("stop_id == %@ AND departureTime > %@", stop.stopId, intDate).sorted(byKeyPath: "departureTime")).prefix(STOP_TIMES_SHOWN_COUNT)
            let theseTimes = theseStops.map({ (stopTime) -> Int in
                
                return stopTime.departureTime//.getDateFromInt()
            }) 
            
            
            return theseTimes
        } else {
            return []
        }
        
    }
    
    public func addPotentialDelay(to stop: Stop) {
        print("add potential delay")
        
        let timestamp: String = "05-30-2017"//Date().dateString
        
        ref.child(timestamp).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var post = currentData.value as? [String: Any], let uid = Auth.auth().currentUser?.uid {
                //var stopForPost: Dictionary<String, AnyObject>
                //stopForPost = post[stop.stopName] as? [String: AnyObject] ?? [:]
                
                var delays: [String: Bool]
                delays = post["delays"] as? [String : Bool] ?? [:]
                var delayCount = post["delayCount"] as? [String: Int] ?? [stop.stopName: 0]
                let uniqID = uid+"-\(stop.stopId)"
                if let _ = delays[uniqID] {
                    //
                    delayCount[stop.stopName]! -= 1
                    delays.removeValue(forKey: uniqID)
                } else {
                    //
                    delayCount[stop.stopName]! += 1
                    delays[uniqID] = true
                }
                post["delayCount"] = delayCount as AnyObject?
                post["delays"] = delays as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            } else {
                print("failed trans")
            }
            print("success trans")
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
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
        
        var minuteDifference = minute - Calendar.current.component(.minute, from: Date())
        var hourDifference = hour - Calendar.current.component(.hour, from: Date())
        
        
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
        var hour = self / 60
        var am = "AM"
        
        if hour > 11 {
            if !(hour > 23) {
            am = "PM"
            }
            hour = hour % 12
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
