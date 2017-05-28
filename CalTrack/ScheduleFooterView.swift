//
//  ScheduleFooterView.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class ScheduleFooterView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet var estimatedTravelTimeLabel: UILabel!
    
    @IBOutlet var originLabel: UILabel!
    
    @IBOutlet var destinationLabel: UILabel!
    
    
    
    // Initializers borrowed from https://gist.github.com/bwhiteley/049e4bede49e71a6d2e2 
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ScheduleFooterView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
