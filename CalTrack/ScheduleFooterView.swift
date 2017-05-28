//
//  ScheduleFooterView.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class ScheduleFooterView: UIView {
    @IBOutlet weak var view: NSObject!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = appColor1
//        if let customView : UIView = UINib(nibName: "ScheduleFooterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView {
//            self.addSubview(customView)
//        }
    }
    
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
