//
//  AppDelegate.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        GMSServices.provideAPIKey("AIzaSyBOYBoKP3VQvrD5ddO2q7gZXpwIgD1Bdik")
        
        
    }
    
    func copyRealmData() {
        if let bUrl = bundleURL("caltrainTimes") {

            let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
            
           // if !FileManager.default.fileExists(atPath: defaultRealmPath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: defaultRealmPath)
                    try FileManager.default.copyItem(at: bUrl, to: defaultRealmPath)
                } catch let error {
                    print("error copying seeds: \(error)")
                    do {
                    try FileManager.default.copyItem(at: bUrl, to: defaultRealmPath)
                    } catch {
                        
                    }
                }
       //     }
        }
     
    }
    
    func checkRealmData() {
        let realm = try! Realm()
        let stopTimes = realm.objects(stop_times.self)//.filter(<#T##predicate: NSPredicate##NSPredicate#>)
        print(stopTimes.count)
    }
    
    func bundleURL(_ name: String) -> URL? {
        return Bundle.main.url(forResource: name, withExtension: "realm")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.copyRealmData()
        let config = Realm.Configuration(
   //         fileURL: bundleURL("caltrainTimes")!,
    //        readOnly: true,
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 8,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 7 {
                    migration.enumerateObjects(ofType: stop_times.className(), { (oldObject, newObject) in
                        let depTime = oldObject!["departure_time"] as! String
                        let arrTime = oldObject!["arrival_time"] as! String
                        
                        let depArr = depTime.components(separatedBy: ":")
                        let firstDep = Int(depArr.first!)!
                        let secondDep = Int(depArr[1])!
                        
                        newObject!["departureTime"] = firstDep * 60 + secondDep
                        
                        let arrArr = arrTime.components(separatedBy: ":")
                        let firstArr = Int(arrArr.first!)!
                        let secondArr = Int(arrArr[1])!
                        
                        newObject!["arrivalTime"] = firstArr * 60 + secondArr
                    })
                }
        }
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let realm = try! Realm()
        
        self.checkRealmData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

