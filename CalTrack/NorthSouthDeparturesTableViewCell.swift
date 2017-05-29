//
//  NorthSouthDeparturesTableViewCell.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class NorthSouthDeparturesTableViewCell: UITableViewCell {
    @IBOutlet var northView: UIView!
    @IBOutlet var northDepartureTimeLabel: UILabel!
    @IBOutlet var northTimeToDepartureLabel: UILabel!
    @IBOutlet var southView: UIView!
    @IBOutlet var southDepartureTimeLabel: UILabel!
    @IBOutlet var southTimeToDepartureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setDepartureTime(time: Date, north:Bool) {
        var timeLabel : UILabel
        var timeRemainingLabel : UILabel
        if north {
            timeLabel = self.northDepartureTimeLabel
            timeRemainingLabel = self.northTimeToDepartureLabel
        } else {
            timeLabel = self.southDepartureTimeLabel
            timeRemainingLabel = self.southTimeToDepartureLabel
        }
        
        timeLabel.text = time.timeOfDepartureText
        timeRemainingLabel.text = time.timeRemainingText

}

}

extension Date {
    var timeRemainingText: String {
        
        var minuteDifference = Calendar.current.component(.minute, from: self) - Calendar.current.component(.minute, from: Date())
        var hourDifference = Calendar.current.component(.hour, from: self) - Calendar.current.component(.hour, from: Date())
        
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
        var hour = Calendar.current.component(.hour, from: self)
        var am = "AM"
        
        if hour > 11 {
            hour = hour % 12
            am = "PM"
        }
        let minute = Calendar.current.component(.minute, from: self)
        var minuteString = String(minute)
        if minuteString.characters.count == 1 {
            minuteString = "0"+minuteString
        }
        return "\(hour):\(minuteString) \(am)"
    }
    }
