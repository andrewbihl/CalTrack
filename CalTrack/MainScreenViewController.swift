//
//  MainScreenViewController.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/28/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController, MapDetailAnimationManager {
    @IBOutlet var detailViewHeightConstraint: NSLayoutConstraint!
    
    private let DETAIL_VIEW_HEIGHT : CGFloat = 100.0
    
    @IBOutlet var routeButton: UIButton!
    @IBOutlet var mapContainerView: UIView!

    @IBOutlet var detailContainerView: UIView!
    
    var mapDetailVC : MapDetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailViewHeightConstraint.constant = DETAIL_VIEW_HEIGHT
        for vc in self.childViewControllers {
            if let detailVC = vc as? MapDetailViewController {
                self.mapDetailVC = detailVC
                return
            }
        }
    }

    func userSwipedUp(vc: MapDetailViewController) -> Bool {
        if !vc.isExpanded {
            self.animateDetailViewController(expand: true)
            return true
        }
        return false
    }
    
    func userSwipedDown(vc: MapDetailViewController) -> Bool {
        if vc.isExpanded {
            self.animateDetailViewController(expand: false)
            return true
        }
        return false
    }
    
    @IBAction func userPressedRouteButton(_ sender: Any) {
        if let vc = self.mapDetailVC {
            vc.toggleRouteMode()
        }
    }
    
    
    public func animateDetailViewController(expand: Bool) {
        let height : CGFloat
        if expand {
            height = (2.0/3)*self.view.frame.size.height
        } else {
            height = DETAIL_VIEW_HEIGHT
        }
        self.detailViewHeightConstraint.constant = height
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.detailContainerView.layoutIfNeeded()
        }) { (finished) in
            
        }
//        UIView.animate(withDuration: 0.25, animations: { 
//            self.view.layoutIfNeeded()
//        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
