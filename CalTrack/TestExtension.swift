//
//  TestExtension.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import Foundation

extension Int {
    
    static func dateToMinutes(date: Date)->Int {
        let interval = date.timeIntervalSince1970
        let minutes = (Int(interval) / 60) % 60
        return minutes
    }
    
    static func currentDateInMinutes()->Int {
        return dateToMinutes(date: Date())
    }
    
}
