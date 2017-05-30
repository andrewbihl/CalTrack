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
        self.southDepartureTimeLabel.isHidden = true
        self.northDepartureTimeLabel.isHidden = true
        self.northTimeToDepartureLabel.isHidden = true
        self.southTimeToDepartureLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setDepartureTime(time: Int, north:Bool) {
        var timeLabel : UILabel
        var timeRemainingLabel : UILabel
        
        if north {
            timeLabel = self.northDepartureTimeLabel
            timeRemainingLabel = self.northTimeToDepartureLabel
        
        } else {
            timeLabel = self.southDepartureTimeLabel
            timeRemainingLabel = self.southTimeToDepartureLabel
        }
        
        timeLabel.isHidden = false
        timeRemainingLabel.isHidden = false
        
        timeLabel.text = time.timeOfDepartureText
        timeRemainingLabel.text = time.timeRemainingText

}

}
