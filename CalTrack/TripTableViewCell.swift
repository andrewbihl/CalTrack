//
//  TripTableViewCell.swift
//  CalTrack
//
//  Created by Andrew Bihl on 6/4/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    @IBOutlet var departureTimeLabel: UILabel!
    @IBOutlet var timeToDepartureLabel: UILabel!
    @IBOutlet var arrivalTimeLabel: UILabel!
    @IBOutlet var timeToArrivalLabel: UILabel!
    @IBOutlet var totalTripTimeLabel: UILabel!
    @IBOutlet var fareLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setTripTimes(departure: Int, arrival: Int, origin: Stop, destination: Stop) {
        departureTimeLabel.text = departure.timeText
        timeToDepartureLabel.text = "Leaves in \(departure.timeRemainingText)"
        arrivalTimeLabel.text = arrival.timeText
        timeToArrivalLabel.text = "Arrives in \(arrival.timeRemainingText)"
        
        totalTripTimeLabel.text = "\(arrival - departure) m travel time"
        
        fareLabel.text = "Fare: \(abs(origin.stopZone - destination.stopZone).farePrice)"
        
    }

}

extension Int {
    public var farePrice: String {
        switch self {
        case 0:
            return "$3.75"
        case 1:
            return "$5.75"
        case 2:
            return "$7.75"
        case 3:
            return "$9.75"
        case 4:
            return "$11.75"
        case 5:
            return "$13.75"
        default:
            return "invalid"
        }
    }
}
