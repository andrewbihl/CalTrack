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
    
    public func setTripTimes(departure: Int, arrival: Int) {
        departureTimeLabel.text = departure.timeText
        timeToDepartureLabel.text = "Leaves in \(departure.timeRemainingText)"
        arrivalTimeLabel.text = arrival.timeText
        timeToArrivalLabel.text = "Arrives in \(arrival.timeRemainingText)"
        
    }

}
