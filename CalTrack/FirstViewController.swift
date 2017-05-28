//
//  FirstViewController.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit
import RealmSwift

class FirstViewController: UIViewController {
    
    var stopTimes: Results<stop_times>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let realm = try! Realm()
        self.stopTimes = realm.objects(stop_times.self)//.filter(<#T##predicate: NSPredicate##NSPredicate#>)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

